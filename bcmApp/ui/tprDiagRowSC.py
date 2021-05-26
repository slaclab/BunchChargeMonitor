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
        self.tdes.channel = self.prefix+':TRG'+self.trign+'_SYS0_TDES'        
        self.tdes.alarmSensitiveContent = True
        self.tdes.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)

        # Create the combo box, and connect the value change action to 
        # the change_label function
        self.combo = PyDMEnumComboBox()
        self.combo.channel = 'TPR:'+self.loca +':'+self.ioc_unit+':'+self.inst+':TRG'+self.trign+'_SOURCE'
#        self.combo.currentIndexChanged.connect(self.change_label)

        # Add enable/disable trigger box
        self.tctl = PyDMEnumComboBox()
        self.tctl.channel = 'TPR:'+self.loca +':'+self.ioc_unit+':'+self.inst+':TRG'+self.trign+'_SYS2_TCTL'   

        row = QHBoxLayout()
        # Add the widgets to the grid, and set the relative stretch for each column
        row.addWidget(self.name,2)
        row.addWidget(self.desc,5)
        row.addWidget(self.twid,2)
        row.addWidget(self.tdes,2)
        row.addWidget(self.combo,3)
        row.addWidget(self.tctl,3)
        # Set overall margins for the grid box
        row.setContentsMargins(6,1,6,0)
        
        self.setLayout(row)
        
