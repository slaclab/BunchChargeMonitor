import os
import socket
import subprocess

from enum import Enum

from epics import PV

from pydm import Display

class FPGAConfig(Display):
    def __init__(self, parent=None, args=None, macros=None):
        super(FPGAConfig, self).__init__(parent, args, macros)

        self.connect_pvs()

        self.ui.tree_gui_btn.clicked.connect(self.handle_tree_gui)
        self.setup_location_label()
        self.setup_Sys_Gen_Label()

    def connect_pvs(self):
        self.sioc_pv_prefix = 'SIOC:{}:{}'.format(\
                self.macros()['AREA'],
                self.macros()['IOC_UNIT'])

        self.type_pv_prefix = '{}:{}:{}'.format(\
                self.macros()['TYPE'],
                self.macros()['AREA'],
                self.macros()['POS'])

        self.cpu = PV('{}:CPU'.format(self.sioc_pv_prefix))
        self.shm = PV('{}:SHM'.format(self.sioc_pv_prefix))
        self.atca_slot = PV('{}:ATCA_SLOT'.format(self.sioc_pv_prefix))

    def setup_location_label(self):
        """
        Convert AppType and Location labels from integers to strings.
        The values are defined in the YAML config.
        """
        pyro = 0
        gap = 1 
        FC = 1
        toroid = 0

        app_type = PV("{}:AppTypeRBV".format(self.type_pv_prefix)).get()
        loc = PV("{}:LocationRBV".format(self.type_pv_prefix)).get()
        app_type_txt = ""
        loc_txt = ""
        
        if self.macros()['TYPE'] == "BLEN":
            if app_type == pyro:
                app_type_txt = "Pyrodetector"
                loc_txt = "BC1" if loc == 0 else "BC2"
            else:
                app_type_txt = "Gap Diode"
                loc_txt = "Injector" if loc == 0 else "BC1"
        if self.macros()['TYPE'] == "TORO":
            loc_txt = self.macros()['AREA']
            if app_type == toroid:
                app_type_txt = "Bergoz Toroid"
            else:
                app_type_txt = "Farady Cup"

        self.ui.appType.setText(app_type_txt)
        self.ui.location.setText(loc_txt)

    def setup_Sys_Gen_Label(self):
        """
        BCM and BLEN have diffent PVs for sysGenVersion this selects the appropriate one
        """
        toro_txt = str(PV("{}:DSPVers".format(self.type_pv_prefix)).get())
        blen_txt = str(PV("{}:{}A:DSPVers".format(self.type_pv_prefix, self.macros()['INST'])).get())
        
        if self.macros()['TYPE'] == "TORO":
            self.ui.sysGenVersion.setText(toro_txt)
        if self.macros()['TYPE'] == "BLEN":
            self.ui.sysGenVersion.setText(blen_txt)

    def handle_tree_gui(self):
        try:
            cmd = self._command()
            subprocess.Popen(cmd, stderr=subprocess.STDOUT)
        except Exception as e:
            print("ERROR: Failed to launch TreeGUI")
            print(e)

    def _command(self):
        """ Creates the TreeGUI command from macros and the environment """
        command = []

        # The values from the caget should be strings already
        # but casting them here covers corner cases and will get
        # error output from cpswTreeGUI when it tries to launch
        cpu = str(self.cpu.get())
        shm = str(self.shm.get())
        atca_slot = str(self.atca_slot.get())

        p_top = self._get_package_top()

        tree_gui = os.path.join('.', p_top, "cpsw/cpswTreeGUI/current/start.sh")
        if(socket.gethostname()=='lcls-dev3'):
            iocData = os.path.join('.', "/nfs/slac/g/lcls/epics/ioc/data")
            print(iocData)
        else:
            iocData = os.path.join('.', "/u1/lcls/epics/ioc/data")
        
        backdoorLoc = os.path.join(iocData, "{}/yaml/config".format(self.macros()['IOC']))
        
        for file in os.listdir(backdoorLoc):
            # revert back to this once new version is released:
            #if file.endswith("backdoor.cpsw.tar.gz"):
            if "AmcCarrierBcm-0x04060002-20220225002553-leosap-f50f9a0_backdoor.cpsw.tar.gz" in file:
                backdoor = os.path.join(backdoorLoc, file)
                break
             

        command.append(tree_gui)
        command.extend(['-c', cpu])
        command.extend(['-S', shm])
        command.extend(['-N', str(atca_slot)])
        command.extend(['-t', backdoor])
        command.extend(['-L', '512'])

        print("\n" + "=" * 64)
        print("Launching cpswTreeGUI with following parameters:")
        # Python slice stride `x::y` take element x and increment iterator by y 
        # We're skipping element 0 since it's the path to TreeGUI's start.sh
        for param, val in zip(command[1::2], command[2::2]):
            print("{}:\t{}".format(param, val))

        print("=" * 64)
        # return " ".join(command)
        return command


    def _get_package_top(self):
        """
        We have no guarantee that PACKAGE_TOP will be defined.
        This method tries its best to find the top of the package tree.
        """
        tries = ["PACKAGE_TOP", "PACKAGE_SITE_TOP"]
        p_top = None
        for t in tries:
            try:
                p_top = os.environ[t]
                if p_top:
                    return p_top
            except:
                continue
        try:
            return "{}/package".format(os.environ["FACILITY_ROOT"])
        except:
            msg  = "Cannot find package tree.\n"
            msg += "Tried $PACKAGE_TOP $PACKAGE_SITE_TOP $FACILITY_ROOT/package"
            raise RuntimeError(msg)

    def ui_filename(self):
        return "fpga_config.ui"

    def ui_filepath(self):
        self.path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(self.path, self.ui_filename())

