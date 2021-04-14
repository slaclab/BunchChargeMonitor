import os

from qtpy.QtCore import QFile
from qtpy.QtWidgets import (QHBoxLayout, QLabel, QLayout, QPushButton,
        QVBoxLayout, QWidget)

from pydm import Display, PyDMApplication
from pydm.widgets import PyDMLabel, PyDMShellCommand


class BCMSummary(Display):
    """ A summary of the salient information from the BCM instrument """
    def __init__(self, parent=None, args=None, macros=None):
        super(BCMSummary, self).__init__(parent=parent, args=args, macros=macros)

        self.pv_prefix = '{}:{}:{}'.format(\
                self.macros()['DEVICE'],
                self.macros()['AREA'],
                self.macros()['POS'])

        self.setup_ui()
        self.load_stylesheet()

    def setup_ui(self):
        """
        Create UI elements
        creates 3 layout sections:
          common PVs, device-specific PVs, and buttons to related displays
        """
        # Main Window properties
        self.setWindowTitle("{} Summary".format(self.macros()['INST']))
        self.main_layout = QVBoxLayout()
        self.main_layout.setSizeConstraint(QLayout.SetNoConstraint)
        self.setLayout(self.main_layout)

        # Common PVs
        self.main_layout.addLayout(self.make_pv_layout('Charge', 'CHRG'))
        self.main_layout.addLayout(self.make_pv_layout('TMIT', 'TMIT'))

        # Device (TORO/FARC) specific PVs
        self.make_device_layout()

        # Related display buttons
        self.main_layout.addLayout(self.make_btn_layout())

    def make_pv_layout(self, name, pv):
        """ Create a horizontal layout with `name` `value` `egu` elements """
        chan = 'ca://{}:{}'.format(self.pv_prefix, pv)
        lo = QHBoxLayout()

        lbl = QLabel(name, self)
        lbl.setObjectName('{}Label'.format(name))

        val = PyDMLabel(self, init_channel=chan)
        val.alarmSensitiveContent = True
        val.setObjectName('{}Value'.format(name))

        units = PyDMLabel(self, init_channel='{}.EGU'.format(chan))
        units.alarmSensitiveContent = True
        units.setObjectName('{}Units'.format(name))

        lo.addWidget(lbl)
        lo.addWidget(val)
        lo.addWidget(units)

        return lo

    def make_device_layout(self):
        """ Create the device-specific (TORO or FARC) section """
        # create an empty QWidget so we can style the background
        lo_widget = QWidget(self)
        dev_lo = QVBoxLayout(lo_widget)
        lo_widget.setObjectName("deviceLayout")

        if self.macros()['DEVICE'] == 'TORO':
            temp_lbl = QLabel('Temperatures')
            temp_lbl.setObjectName('deviceLabel')
            dev_lo.addWidget(temp_lbl)

            dev_lo.addLayout(self.make_pv_layout('Toroid', 'Temp'))
            dev_lo.addLayout(self.make_pv_layout('Amp', 'TempAmp'))
            dev_lo.addLayout(self.make_pv_layout('Electronics', 'TempElc'))

        else: # FARC
            curr_lbl = QLabel('Faraday Cup')
            curr_lbl.setObjectName('deviceLabel')
            dev_lo.addWidget(curr_lbl)

            dev_lo.addLayout(self.make_pv_layout('Average Current', 'I'))
            dev_lo.addLayout(self.make_pv_layout('Trigger Rate', 'RATE'))
            dev_lo.addLayout(self.make_pv_layout('Current / Rate', 'IPerRate'))

        self.main_layout.addWidget(lo_widget)


    def make_btn_layout(self):
        """ Create the Plot and Expert screen buttons """
        plt_disp, expert_disp = self.get_related_displays()

        btn_lo = QHBoxLayout()
        plt_btn = self.create_btn("Plot...", "{}".format(plt_disp))
        expert_btn = self.create_btn("Expert...", "{}".format(expert_disp))

        btn_lo.addWidget(plt_btn)
        btn_lo.addWidget(expert_btn)

        return btn_lo


    def create_btn(self, text, path):
        """
        Creates a button linking to another display

        Params
        text: str    button text
        path: str    path to display

        Returns
        PyDMShellCommand
        """
        m = 'AREA={},UNIT={},MAD={},prefix={},carrier_prefix={}'.format(\
            self.macros()['AREA'],self.macros()['POS'], self.macros()['INST'],
            self.pv_prefix, 'AMCC:{}:{}'.format(self.macros()['AREA'], self.macros()['POS']))
        cmd = 'edm -x -m {} {}'.format(m, path)
        btn = PyDMShellCommand(self, command=cmd, title='{}'.format(self.macros()['INST']))
        btn.setText(text)
        return btn

    def get_related_displays(self):
        """ Get the file paths for the related displays """
        pref = '{}/edm/display/gadc'.format(os.environ['TOOLS'])

        if self.macros()['DEVICE'] == 'TORO':
            return ('{}/bcmIMPlot.edl'.format(pref),
                    '{}/bcmIMTop.edl'.format(pref))
        else:
            return ('{}/bcmFcPlot.edl'.format(pref),
                    '{}/bcmFCTop.edl'.format(pref))

    def load_stylesheet(self):
        fname = 'bcm.qss'
        print('Loading custom stylesheet at {}'.format(fname))
        file = QFile(fname)
        file.open(QFile.ReadOnly | QFile.Text)
        stylesheet = file.readAll()
        PyDMApplication.instance().setStyleSheet(str(stylesheet))

    def ui_filepath(self):
        """
        Path to the QtDesigner ui file.
        We aren't using one, return None
        """

        return None
