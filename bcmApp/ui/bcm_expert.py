import os

from epics import caget

from pydm import Display

class bcm_expert(Display):
    def __init__(self, parent=None, args=None, macros=None):
        super(bcm_expert, self).__init__(parent, args, macros)
        
        self.setup_bergoz()
        #self.setup_coef()
        #self.setup_FPGAConfig()
        self.setup_trig()
    
    def setup_bergoz(self):
        print(self.macros())
        Bergoz = PyDMEDMDisplayButton(filename="bergozMain.ui")
        Bergoz.openInNewWindow = True
        Bergoz.macros = "prefix=TORO:{}:{},carrier_prefix=AMCC:{}:{},MAD={}".format(
                    self.macros()["AREA"],
                    self.macros()["POS"],
                    self.macros()["AREA"],
                    self.macros()["POS"],
                    self.macros()["INST"]) 
    
    def setup_trig(self):
        rate_mode_pv = "TPR:{}:{}:{}:MODE".format(
                self.macros()["AREA"],
                self.macros()["IOC_UNIT"],
                self.macros()["INST"])
        rate_mode = caget(rate_mode_pv)
        print(rate_mode_pv)
        print(rate_mode)
            
        if rate_mode == 1:
            #Trig = PyDMRelatedDisplayButton(filename="$PYDM/evnt/tprDiagSC.ui")       
            Trig = PyDMRelatedDisplayButton(filename="tprDiagSC.ui")#used to test without having to push the screen
        else:
            #Trig = PyDMRelatedDisplayButton(filename="$PYDM/evnt/tprDiagNC.ui")       
            Trig = PyDMRelatedDisplayButton(filename="tprDiagNC.ui")#used to test without having to push the screen    
                
        Trig.openInNewWindow = True
        if not(self.macros()["POS"] == "LI11"):
            Trig.macros = "LOCA={},IOC_UNIT={},INST=0,IOC={}, CPU={}, CRATE={}".format(
                self.macros()["AREA"],
                self.macros()["IOC_UNIT"],
                self.macros()["IOC"],
                self.macros()["CPU"],
                self.macros()["CRATE"])
        else:
            Trig.macros = "AREA={},POS={},INST=1,CHAN={}_Calibration,IOC_UNIT={},IOC={}, CPU={}, CRATE={}".format(
                    self.macros()["AREA"],
                    "IN10",
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
