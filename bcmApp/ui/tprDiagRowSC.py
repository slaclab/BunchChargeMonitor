from qtpy import QtCore
from pydm import Display
from qtpy.QtCore import Qt
from qtpy.QtWidgets import QWidget, QHBoxLayout
from pydm.widgets import PyDMLabel, PyDMEnumComboBox, PyDMLineEdit


class test_widget(Display):

    def __init__(self, args=[], macros=None):
        super(test_widget, self).__init__(args=args, macros=macros)

        # These macros are set for the whole page
        #self.prefix = macros['PREFIX']
        self.prefix = 'TPR:'+macros['LOCA']+':'+macros['IOC_UNIT']+':'+macros['INST']
        #self.prefix = 'FARC:GUNB:999'
        self.loca = macros['LOCA']
        #self.loca = 'GUNB'
        self.ioc_unit = macros['IOC_UNIT']
        #self.ioc_unit = 'FC01'
        self.inst = macros['INST']
        #self.inst = '0'

        # This macro is set on each row 
        self.trign = macros['TRIGN']

        # Define the map of what PVs relate to the items in the combo box
        # This could be automated if the two sets both just use the macro 
        self.map = {'Channel 00': '00', 
                    'Channel 01': '01', 
                    'Channel 02': '02', 
                    'Channel 03': '03', 
                    'Channel 04': '04', 
                    'Channel 05': '05', 
                    'Channel 06': '06', 
                    'Channel 07': '07', 
                    'Channel 08': '08', 
                    'Channel 09': '09', 
                    'Channel 10': '10', 
                    'Channel 11': '11', 
                    'Channel 12': '12', 
                    'Channel 13': '13', 
                    'Channel 14': '14', 
                    'Channel 15': '15', 
                    'Channel 16': '16' }

        # Add the PV Name widget
        self.name = PyDMLabel()
        self.name.channel = 'TPR:'+self.loca+':'+self.ioc_unit+':'+self.inst+':TPRTRIG'+self.trign
        self.name.alarmSensitiveContent = False

        # Add the PV Desc widget
        self.desc = PyDMLabel()
        self.desc.channel = 'TPR:'+self.loca+':'+self.ioc_unit+':'+self.inst+':TPRTRIG'+self.trign+'.DESC'
        self.desc.alarmSensitiveContent = False

        # Add the TWID widget
        self.twid = PyDMLineEdit()
        self.twid.channel = self.prefix+':TRG'+self.trign+'_SYS2_TWID'
        self.twid.alarmSensitiveContent = True
        self.twid.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)

        # Add the TDES widget (without defining a PV),
        self.tdes = PyDMLineEdit()
        self.tdes.channel = self.prefix+':TRG'+self.trign+'_SYS2_TDES'
        self.tdes.alarmSensitiveContent = True
        self.tdes.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)

        # Create the combo box, and connect the value change action to 
        # the change_label function
        self.combo = PyDMEnumComboBox()
        self.combo.channel = 'TPR:'+self.loca +':'+self.ioc_unit+':'+self.inst+':TRG'+self.trign+'_SOURCE'
        self.combo.currentIndexChanged.connect(self.change_label)

        # Add the rate widget (without defining a PV)
        self.rate = PyDMLabel()
        self.rate.alarmSensitiveContent = True
        self.rate.setStyleSheet('qproperty-alignment: AlignCenter')

        # Add enable/disable trigger box
        self.tctl = PyDMEnumComboBox()
        self.tctl.channel = 'TPR:'+self.loca +':'+self.ioc_unit+':'+self.inst+':CH'+self.trign+'_SYS2_TCTL'
        self.tctl.currentIndexChanged.connect(self.change_label)        

        row = QHBoxLayout()
        # Add the widgets to the grid, and set the relative stretch for each column
        row.addWidget(self.name,1)
        row.addWidget(self.desc,3)
        row.addWidget(self.twid,1)
        row.addWidget(self.tdes,1)
        row.addWidget(self.combo,1)
        row.addWidget(self.rate,1)
        row.addWidget(self.tctl,1)
        # Set overall margins for the grid box
        row.setContentsMargins(6,1,6,0)
        
        self.setLayout(row)
        
    def change_label(self, index):
        #print(self.combo.currentText())
        #print(self.map[self.combo.currentText()])
        if self.combo.currentText():
            chan = self.map[self.combo.currentText()]
            self.rate.channel = 'TPR:'+self.loca+':'+self.ioc_unit+':'+self.inst+':CH'+chan+'_RATE'

