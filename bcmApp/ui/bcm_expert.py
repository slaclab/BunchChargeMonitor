import os

from epics import caget

from pydm import Display
from pydm.widgets import PyDMRelatedDisplayButton


class BCMexpert(Display):
    def __init__(self, parent=None, args=None, macros=None):
        super(BCMexpert, self).__init__(parent, args, macros)
        
        self.setup_bergoz()
        self.setup_coef()
        self.setup_FPGAConfig()
        self.setup_trig()
    
    def setup_bergoz(self):
        self.ui.Bergoz.openInNewWindow = True
        self.ui.Bergoz.macros = "LOCA={},IOC_UNIT={},INST=0,IOC={}, CPU={}, CRATE={}".format(
                self.macros()["AREA"],
                self.macros()["IOC_UNIT"],
                self.macros()["IOC"],
                self.macros()["CPU"],
                self.macros()["CRATE"])       
    
    def setup_coef(self):
        self.ui.Coef.openInNewWindow = True
        self.ui.Coef.macros = "PREFIX=TORO:{}:{}:{}{}".format(
                self.macros()["AREA"],
                self.macros()["POS"],
                self.macros()["INST"],
                self.macros()["MAD"])
                
    def setup_FPGAConfig(self):
        self.ui.FPGAConfig.openInNewWindow = True
        self.ui.FPGAConfig.macros = "AREA={},IOC_UNIT={},POS={},TYPE={}".format(
                    self.macros()["AREA"],
                    self.macros()["IOC_UNIT"],
                    self.macros()["IOC_UNIT"],
                    "TORO"
                    )
    
    def setup_trig(self):
        rate_mode_pv = "TPR:{}:{}:{}:MODE".format(
                self.macros()["AREA"],
                self.macros()["IOC_UNIT"],
                self.macros()["INST"])
        rate_mode = caget(rate_mode_pv)

        if rate_mode == 1:
            #self.ui.Trig.filename = "$PYDM/evnt/tprDiagSC.ui"      
            self.ui.Trig.filename = "tprDiagSC.ui"#used to test without having to push the screen
        else:
            #self.ui.Trig.filename="$PYDM/evnt/tprDiagNC.ui"      
            self.ui.Trig.filename="tprDiagNC.ui"#used to test without having to push the screen      
        self.ui.Trig.openInNewWindow = True
        if not(self.macros()["AREA"] == "LI11"):
            self.ui.Trig.macros = "LOCA={},IOC_UNIT={},INST=0,IOC={}, CPU={}, CRATE={}".format(
                self.macros()["AREA"],
                self.macros()["IOC_UNIT"],
                #self.macros()["INST"],
                self.macros()["IOC"],
                self.macros()["CPU"],
                self.macros()["CRATE"])
        else:
            self.ui.Trig.macros = "AREA={},POS={},INST=0,CHAN={}_Calibration,IOC_UNIT={},IOC={}, CPU={}, CRATE={}".format(
                    "IN10",
                    self.macros()["POS"],
                    self.macros()["CHAN"],
                    self.macros()["IOC_UNIT"],
                    self.macros()["IOC"],
                    self.macros()["CPU"],
                    self.macros()["CRATE"])
        #there are only one set of triggers per slot and they are only mapped to one set of PVs with INST=0
             
        
    def ui_filename(self):
        return "bcm_expert.ui"

    def ui_filepath(self):
        self.path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(self.path, self.ui_filename())
