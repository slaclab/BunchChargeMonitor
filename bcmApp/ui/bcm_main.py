

import os

import pyqtgraph as pg
from qtpy.QtCore import Signal, QObject, QPoint, Qt
from qtpy.QtGui import QColor, QFont
from qtpy.QtSvg import QSvgWidget
from qtpy.QtWidgets import (QAction, QDialog, QGridLayout, QHBoxLayout, QLabel,
                            QMenu, QPushButton, QRadioButton, QTextEdit,
                            QVBoxLayout, QWidget, QSpacerItem, QSizePolicy, QGroupBox)

from pydm import Display
from edmbutton import PyDMEDMDisplayButton
from pydm.widgets.display_format import DisplayFormat
from pydm.widgets import (PyDMLineEdit, PyDMSlider, PyDMRelatedDisplayButton, 
                          PyDMByteIndicator, PyDMEnumComboBox, PyDMLabel)
from pydm.widgets.waveformplot import WaveformCurveItem
from epics import caget

left_lbl = 'ADC Counts'
btm_lbl = 'nanoseconds'

class WaveformType:
    RAW = "Raw"
    INT = "Integration Window"
    RAW_TIMES = "Raw times Weight Fn"

class Sensor:
    A = "A"
    B = "B"

bcm_pv = { "x": ":SAMP_TIME.VALA", WaveformType.RAW: ":RWF_U16.VALA", WaveformType.INT: ":IWF_U16.VALA",
        WaveformType.RAW_TIMES: ":S_P_WF", "window": ":SCL_WF"}

# NC (Normal Conducting) and SC (Super Conducting) BCM IOCs have differences in
# a few PV names. The differences are in the dictionaries below while the PV
# names are not unified.
scPVs = {"charge":"CHRG","nel":"TMIT"}
ncPVs = {"charge":"TMIT_PC","nel":"TMIT"}

class CalPlotCtxBox(pg.ViewBox, QObject):
    """ Implements a custom right click menu for Calibration plots """
    y_src_changed = Signal(str, str)
    int_window_changed = Signal(int)
    reset_view = Signal()

    def __init__(self, plot, menuItems=None, parent=None):
        super(CalPlotCtxBox, self).__init__(parent)
        self.plot = plot
        self.menuItems = menuItems
        self.menu = None

    def get_menu(self):
        if self.menu is None:
            self.menu = QMenu()
            self.view_all = QAction("View All", self)
            self.view_all.triggered.connect(self.autoRange)

            self.reset = QAction("Reset View (1 us)", self)
            self.reset.triggered.connect(self.reset_view.emit)

            self.show_int_window = QAction("Show Weight Function")
            self.show_int_window.setCheckable(True)
            self.show_int_window.setChecked(True)
            self.show_int_window.triggered.connect(self.emit_int_window_changed)


            self.y_datasrc = QMenu("Data Source")
            try:
                # The plot INST macro is something like BZ21BA where
                # BZ21B is the MAD name and A is the instr
                sensor = self.plot.macros["INST"][-1]
            except KeyError:
                raise KeyError("'INST' macro was not defined! Please start this screen with the 'INST' macro!")

            rwf = QAction("Raw Waveform (Stream0)", self.y_datasrc)
            rwf_mult = QAction("Raw Waveform times Weight Function", self.y_datasrc)
            iwf = QAction("Integration Window Waveform (Stream3)", self.y_datasrc)
            # PyQt5 requires a workaround for passing arguments to slots.
            # We use lambdas
            print(sensor, WaveformType.RAW, WaveformType.RAW_TIMES, WaveformType.INT).
            rwf.triggered.connect(lambda: self.emit_ychange(
                WaveformType.RAW, sensor))
            rwf_mult.triggered.connect(lambda: self.emit_ychange(
                WaveformType.RAW_TIMES, sensor))
            iwf.triggered.connect(lambda: self.emit_ychange(
                WaveformType.INT, sensor))

            self.y_datasrc.addAction(rwf)
            self.y_datasrc.addAction(rwf_mult)
            self.y_datasrc.addAction(iwf)

            self.menu.addAction(self.view_all)
            self.menu.addAction(self.reset)
            self.menu.addSeparator()

            self.menu.addMenu(self.y_datasrc)
            self.menu.addAction(self.show_int_window)
        return self.menu

    def raiseContextMenu(self, ev):
        menu = self.get_menu()
        pos = ev.screenPos()
        menu.popup(QPoint(pos.x(), pos.y()))

    def emit_ychange(self, wf, sensor):
        self.y_src_changed.emit(wf, sensor)

    def emit_int_window_changed(self):
        self.int_window_changed.emit(self.show_int_window.isChecked())


class BcmCalPlot(pg.PlotWidget):
    """
    BcmCalPlot is a waveform plot with extra features useful for calibration.

    The PyDMWaveformPlot doesn't have the flexibility needed to make a more
    interactive experience. This class directly subclasses pyqtgraph PlotWidget
    in order to implement a custom right click menu.
    """

    src_changed = Signal(str, str)
    pg.setConfigOption('leftButtonPan', False)

    def __init__(self, macros, sensor, wf, parent=None):
        super(BcmCalPlot, self).__init__(parent, viewBox=CalPlotCtxBox(self))
        self.plotItem1 = self.getPlotItem()
        self.plotItem1.hideButtons()
        self.plotItem1.vb.y_src_changed.connect(self.y_changed)
        self.plotItem1.vb.int_window_changed.connect(self.show_int_window)
        self.plotItem1.vb.reset_view.connect(self.reset_view)
        self.plotItem1.vb.sigResized.connect(self.update_views)

        self.plotItem2 = pg.ViewBox()
        self.plotItem1.showAxis('right')
        self.plotItem1.scene().addItem(self.plotItem2)
        self.plotItem1.getAxis('right').linkToView(self.plotItem2)
        self.plotItem2.setXLink(self.plotItem1)
        self.plotItem1.getAxis('right').setTicks([[(-1,'-1'), (0, '0'), (1, '1')],[]])
        self.plotItem1.getAxis('right').setLabel('Weight Function Multipliers')
        rightAxisPen = pg.mkPen(color=(0, 255, 255))
        self.plotItem1.getAxis('right').setPen(rightAxisPen)
        self.plotItem2.setMouseEnabled(y=None)

        self.macros = macros
        self.sensor = sensor       # Sensor 
        self.wf = wf               # WaveformType 
        self.curve = WaveformCurveItem(color=QColor("#aaaaaa"))
        self.window_curve = WaveformCurveItem(color=QColor("#00ffff"), lineWidth=2, lineStyle=Qt.DashLine)
        self.curve.data_changed.connect(self.redraw_plot)
        self.window_curve.data_changed.connect(self.redraw_plot)

        self.plotItem1.addItem(self.curve)

        self.setXRange(0, 1000)

        self.label_plot()
        self._set_data_src()

        self.plotItem2.addItem(self.window_curve)
        self.plotItem2.setGeometry(self.plotItem1.vb.sceneBoundingRect())

    def y_changed(self, wf, sensor):
        if self.wf == wf and self.sensor == sensor:
            return
        self.wf = wf
        self.label_plot()
        self._set_data_src()
        self.redraw_plot()
        self.reset_view()

    def update_views(self):
        self.plotItem2.setGeometry(self.plotItem1.vb.sceneBoundingRect())
        self.plotItem2.linkedViewChanged(self.plotItem1.vb, self.plotItem2.XAxis)

    def show_int_window(self, state):
        self.plotItem2.addItem(self.window_curve) if state else self.plotItem2.removeItem(self.window_curve)

    def label_plot(self):
        self.plotItem1.setLabels(
                left = left_lbl,
                bottom = btm_lbl)
        self.plotItem1.setTitle(
                "{} {}".format(self.macros["CHAN"],
                                 self.wf))

    def _set_data_src(self):
        src_pv_prefix = "ca://{}:{}:{}".format(
                self.macros["TYPE"],
                self.macros["AREA"],
                self.macros["POS"])
        x_pv = "{}{}".format(src_pv_prefix, bcm_pv["x"])                
        y_pv = "{}:{}{}".format(src_pv_prefix,self.macros["INST"], bcm_pv[self.wf])
        window_pv = "{}:{}{}".format(src_pv_prefix,self.macros["INST"], bcm_pv["window"])      
        print(x_pv, y_pv, window_pv)

        for curve_ch, window_ch in (self.curve.channels(), self.window_curve.channels()):
            try:
                curve_ch.disconnect()
                window_ch.disconnect()
            except AttributeError:
                continue

        self.curve.x_address = x_pv
        self.curve.y_address = y_pv

        self.window_curve.x_address = x_pv
        self.window_curve.y_address = window_pv

        for curve_ch, window_ch in (self.curve.channels(), self.window_curve.channels()):
            curve_ch.connect()
            window_ch.connect()


        self.src_changed.emit(self.wf, self.sensor)

    def redraw_plot(self):
        self.curve.redrawCurve()
        self.window_curve.redrawCurve()

    def reset_view(self):
        # y range might have got a little weird.
        self.enableAutoRange(axis=pg.ViewBox.YAxis)
        self.setXRange(0, 1000)



class BcmPyDMSlider(PyDMSlider):
    """ PyDMSlider with a PyDMLineEdit instead of label and only even values """
    def __init__(self, macros, parent=None, ch=None):
        super(BcmPyDMSlider, self).__init__(parent)
        self.macros = macros
        self.sensor = ch.split(":")[0]
        self.window_edge = ch.split(":")[-1]
        self.pv = "{}:{}:{}:{}".format(\
                self.macros["TYPE"],
                self.macros["AREA"],
                self.macros["POS"],
                self.window_edge)

        self.value_label = PyDMLineEdit(self)
        self.value_label.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)

        self.orientation = Qt.Horizontal
        self.userDefinedLimits = True
        self.showLimitLabels = False
        self.userMinimum = 0
        self.userMaximum = 1000
        self.num_steps = self.userMaximum - self.userMinimum + 1

        # call PyDMSlider's setup again to put our label in the right place
        self.setup_widgets_for_orientation(self.orientation)
        #self.reset_slider_limits()

        self._change_channel()

    def plot_src_changed(self, wf, sensor):
        self.sensor = sensor
        self.pv = "{}:{}:{}:{}".format(\
                self.type,
                self.macros["AREA"],
                self.macros["POS"],
                self.window_edge)

        self._change_channel()

    def _change_channel(self):
        self.value_label.channel = self.pv
        self.channel = self.pv



class BcmWeightFnSliders(QWidget):
    """ A widget with sliders to control the weight function edges + offset """

    def __init__(self, macros, parent=None, sensor=None):
        super(BcmWeightFnSliders, self).__init__(parent)
    
        self.macros = macros
        self.sensor = sensor

        self.pre_slider = BcmPyDMSlider(macros, self, ch="{}:TIME_PRE".format(self.sensor))
        self.mid_slider = BcmPyDMSlider(macros, self, ch="{}:TIME_MID".format(self.sensor))
        self.pos_slider = BcmPyDMSlider(macros, self, ch="{}:TIME_POS".format(self.sensor))

        self.pre_label = QLabel("End of Pedestal (ns)")
        self.mid_label = QLabel("End of Transition Region (ns)")
        self.pos_label = QLabel("Duration of Beam Pulse (ns)")

        self.sliders = [self.pre_slider, self.mid_slider, self.pos_slider]
        self.labels = [self.pre_label, self.mid_label, self.pos_label]


        self.setup_ui()

    def setup_ui(self):
        # set label fonts
        lbl_font = self.pre_label.font()
        lbl_font.setPointSize(11)

        self.layout = QHBoxLayout()
        slider_layouts = [QVBoxLayout() for i in range(3)]

        for lo, label, slider in zip(slider_layouts, self.labels, self.sliders):
            label.setFont(lbl_font)
            label.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
            lo.addWidget(label)
            lo.addWidget(slider)
            self.layout.addLayout(lo)

        self.setLayout(self.layout)


    def plot_src_changed(self, wf, inst):
        for slider in self.sliders:
            slider.plot_src_changed(wf, inst)

class BcmWeightFnSliderSC(QWidget):
    """ A widget with single sliders to control the weight function for SC mode """

    def __init__(self, macros, parent=None, sensor=None):
        super(BcmWeightFnSliderSC, self).__init__(parent)
    
        self.macros = macros
        self.sensor = sensor

        self.pre_slider = BcmPyDMSlider(macros, self, ch="{}:TIME_PRE".format(self.sensor))

        self.pre_label = QLabel("Average Window (ns)")

        self.sliders = [self.pre_slider]
        self.labels = [self.pre_label]
        
        self.temperature_table_heading_null = QLabel("")
        self.temperature_table_heading = QLabel("Temperature (K)")
  
        
        self.toro_text = QLabel("Toroid")
        self.amp_text = QLabel("Amplifier")
        self.bergoz_elc_text = QLabel("Bergoz")
        self.atca_elc_text = QLabel("ATCA")        

        self.toro_lbl = PyDMLabel()
        self.toro_lbl.alarmSensitiveBorder = True
        self.toro_lbl.alarmSeverityChanged(1)
        self.toro_lbl.channel = "ca://TORO:{}:{}:TempToro".format(
                              self.macros["AREA"],
                              self.macros["POS"])
                              
        self.amp_lbl = PyDMLabel()
        self.amp_lbl.channel = "ca://TORO:{}:{}:TempAmp".format(
                              self.macros["AREA"],
                              self.macros["POS"])
        self.bergoz_elc_lbl = PyDMLabel()
        self.bergoz_elc_lbl.channel = "ca://TORO:{}:{}:TempBergozElc".format(
                              self.macros["AREA"],
                              self.macros["POS"])
                              
        self.atca_elc_lbl = PyDMLabel()
        self.atca_elc_lbl.channel = "ca://TORO:{}:{}:TempATCAElc".format(
                              self.macros["AREA"],
                              self.macros["POS"])                              

        self.temperature_labels = [self.toro_text, self.amp_text, self.bergoz_elc_text, self.atca_elc_text]
        self.temperature_chan = [self.toro_lbl, self.amp_lbl, self.bergoz_elc_lbl, self.atca_elc_lbl]
        self.temperature_heading = [self.temperature_table_heading_null,self.temperature_table_heading ,self.temperature_table_heading_null, self.temperature_table_heading_null]
        
        
        self.setup_ui()

    def setup_ui(self):
        # set label fonts
        lbl_font = self.pre_label.font()
        lbl_font.setPointSize(11)

        self.layout = QHBoxLayout()
        slider_layouts = [QVBoxLayout() for i in range(3)]
        temperature_layout = QVBoxLayout()
        temperature_element_layout = [QVBoxLayout() for i in range(4)]
        

        for lo, label, slider in zip(slider_layouts, self.labels, self.sliders):
            label.setFont(lbl_font)
            label.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
            lo.addWidget(label)
            lo.addWidget(slider)
            self.layout.addLayout(lo)
        
        for tb, heading, label, channel in zip(temperature_element_layout,self.temperature_heading, self.temperature_labels, self.temperature_chan):
            heading.setFont(lbl_font)
            heading.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
            label.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
            channel.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
            tb.addWidget(heading)
            tb.addWidget(label)
            tb.addWidget(channel)
            self.layout.addLayout(tb)
            

        self.setLayout(self.layout)


    def plot_src_changed(self, wf, inst):
        for slider in self.sliders:
            slider.plot_src_changed(wf, inst)



class BCMExpert(Display):
    """ The main calibration display. """
    def __init__(self, parent=None, args=None, macros=None):
        super(BCMExpert, self).__init__(parent=parent, args=args, macros=macros)
        try:
            # Check if the code is running in NC (including FACET) 
            # or SC accelerator.
	        self.isSC = self.macros()["isSC"]
	    
        except KeyError:
            # If the macro is not found, we assume NC accelerator as this code
            # is legacy in NC and more recent to SC.
	        self.isSC = False
	        
        try:
	        self.type = self.macros()["TYPE"]
        except KeyError:
	        self.type = "TORO"
	        self.macros()["TYPE"] = "TORO"
	    

        self.setWindowTitle("Bunch Charge {}".format(
            self.macros()["CHAN"]))   

        if self.isSC:
            self.pvDict = scPVs
        else:
            self.pvDict = ncPVs

        """
        We appended the A or B AMC card to the end of the INST macro in
        the Qt Designer file.
        eg: INST = BZ21BA but the MAD name is actually just BZ21B
        """
        self.mad = self.macros()["INST"][:-1]
        if (self.macros()["INST"][-1] == 'A'):
            self.sensor = Sensor.A
        else:
            self.sensor = Sensor.B

        self.setMinimumSize(725, 500)
        self.main_layout = QVBoxLayout()

        self.setLayout(self.main_layout)

        spacer1 = QSpacerItem(20, 30, QSizePolicy.Expanding)
        spacer2 = QSpacerItem(20, 30, QSizePolicy.Expanding)

        self.setup_header()
        self.main_layout.addItem(spacer1)
        self.setup_charge_info()
        self.main_layout.addItem(spacer2)
        self.setup_plots()
        self.setup_buttons()

    def setup_header(self):
        self.header_layout = QHBoxLayout()
        self.header_layout.setSpacing(23)

        font = self.font()
        font.setPointSize(11)

        stream_lbl = QLabel("Stream")
        stream_lbl.setMaximumWidth(60)
        stream_lbl.setFont(font)

        stream_led = PyDMByteIndicator()
        stream_led.channel = "ca://{}:{}:{}:AutoRearmRBV".format(
                              self.type,
                              self.macros()["AREA"],
                              self.macros()["POS"])
        stream_led.showLabels = False
        stream_led.setMaximumWidth(35)

        stream_combo = PyDMEnumComboBox()
        stream_combo.channel = "ca://{}:{}:{}:ACCESS".format(
                                self.type,
                                self.macros()["AREA"],
                                self.macros()["POS"])
        stream_combo.setFont(font)
        stream_combo.setMinimumWidth(100)

        spacer1 = QSpacerItem(40, 20, QSizePolicy.Expanding)
        spacer2 = QSpacerItem(40, 20, QSizePolicy.Expanding)

        self.header_layout.addItem(spacer1)
        self.header_layout.addWidget(stream_lbl)
        self.header_layout.addWidget(stream_led)
        self.header_layout.addWidget(stream_combo)
        self.header_layout.addItem(spacer2)

        self.main_layout.addLayout(self.header_layout)

    def setup_charge_info(self):
        self.charge_layout = QHBoxLayout()

        font = self.font()
        font.setPointSize(11)
        charge_lbl1 = QLabel("{} TMIT".format(
                            self.macros()["CHAN"]))                                
        charge_lbl1.setFont(font)
       
        nel_lbl = PyDMLabel()
        nel_lbl.setText("NEL")
        nel_lbl.channel = "ca://{}:{}:{}:{}".format(
                              self.type,
                              self.macros()["AREA"],
                              self.macros()["POS"],
                              self.pvDict["nel"])
        nel_lbl.setStyleSheet("background-color: rgb(0, 0, 0);\
                                    font: 11pt 'Sans Serif';\
                                    color: rgb(0, 255, 0);\
                                    border-color: rgb(0, 255, 0);")
        nel_lbl.precisionFromPV = False                            
        nel_lbl.precision = 2                          
        nel_lbl.displayFormat = DisplayFormat.Exponential 
        nel_lbl.setMinimumWidth(100)
        nel_lbl.setMaximumWidth(100)
 
        charge_lbl2 = QLabel("Nel")
        charge_lbl2.setFont(font)
        
        tmit_pc_lbl = PyDMLabel()
        tmit_pc_lbl.setText("charge")
        if(self.type == "TORO"):
            tmit_pc_lbl.channel = "ca://{}:{}:{}:{}".format(
                              self.type,
                              self.macros()["AREA"],
                              self.macros()["POS"],
                              self.pvDict["charge"])
        else:
            tmit_pc_lbl.channel = "ca://{}:{}:{}:{}".format(
                              self.type,
                              self.macros()["AREA"],
                              self.macros()["POS"],
                              "CHRG")
        tmit_pc_lbl.setStyleSheet("background-color: rgb(0, 0, 0);\
                                    font: 11pt 'Sans Serif';\
                                    color: rgb(0, 255, 0);\
                                    border-color: rgb(0, 255, 0);")
        tmit_pc_lbl.setMinimumWidth(100)
        tmit_pc_lbl.setMaximumWidth(100)
        
        tmit_pc_lbl.precisionFromPV = False
        tmit_pc_lbl.precision = 3
        
        charge_lbl3 = QLabel("pC")
        charge_lbl3.setFont(font)
        
        tmit_pc_lbl_bsss = PyDMLabel()
        tmit_pc_lbl_bsss.setText("charge")
        if(self.type == "TORO"):
            tmit_pc_lbl_bsss.channel = "ca://{}:{}:{}:{}".format(
                              self.type,
                              self.macros()["AREA"],
                              self.macros()["POS"],
                              "CHRGSCH1H")
        else:
            tmit_pc_lbl_bsss.channel = "ca://{}:{}:{}:{}".format(
                              self.type,
                              self.macros()["AREA"],
                              self.macros()["POS"],
                              "CHRG")
        tmit_pc_lbl_bsss.setStyleSheet("background-color: rgb(0, 0, 0);\
                                    font: 11pt 'Sans Serif';\
                                    color: rgb(0, 255, 0);\
                                    border-color: rgb(0, 255, 0);")
        tmit_pc_lbl_bsss.setMinimumWidth(100)
        tmit_pc_lbl_bsss.setMaximumWidth(100)
        
        tmit_pc_lbl_bsss.precisionFromPV = False
        tmit_pc_lbl_bsss.precision = 3
 
        charge_lbl4 = QLabel("pC (from bsss)")
        charge_lbl4.setFont(font)
        
        spacer1 = QSpacerItem(40, 20, QSizePolicy.Expanding)
        spacer2 = QSpacerItem(40, 20, QSizePolicy.Expanding)
        spacer3 = QSpacerItem(40, 20, QSizePolicy.Expanding)
        spacer4 = QSpacerItem(40, 20, QSizePolicy.Expanding)
        spacer5 = QSpacerItem(40, 20, QSizePolicy.Expanding)
    
        self.charge_layout.addItem(spacer1)
        self.charge_layout.addWidget(charge_lbl1)
        self.charge_layout.addItem(spacer2)
        self.charge_layout.addWidget(nel_lbl)
        self.charge_layout.addWidget(charge_lbl2)
        self.charge_layout.addItem(spacer3)
        self.charge_layout.addWidget(tmit_pc_lbl)
        self.charge_layout.addWidget(charge_lbl3)
        self.charge_layout.addItem(spacer4)
        self.charge_layout.addWidget(tmit_pc_lbl_bsss)
        self.charge_layout.addWidget(charge_lbl4)
        self.charge_layout.addItem(spacer5)

        self.main_layout.addLayout(self.charge_layout)
        

    def setup_buttons(self):
        self.btn_layout = QHBoxLayout()
        
        if not(self.isSC):
            if(not(self.type == "FARC")):
                calb_btn = PyDMRelatedDisplayButton(filename="bcm_main.py")
                calb_btn.setText("Calibration...")
                calb_btn.openInNewWindow = True
                calb_btn.macros = "AREA={},POS={},INST=1,CHAN={}_Calibration,IOC_UNIT={},IOC={}, CPU={}, CRATE={}".format(
                    self.macros()["AREA"],
                    self.macros()["POS"],
                    self.macros()["CHAN"],
                    self.macros()["IOC_UNIT"],
                    self.macros()["IOC"],
                    self.macros()["CPU"],
                    self.macros()["CRATE"]) 
            else:
                ammeter_btn = PyDMEDMDisplayButton(filename="bcmFCMain.edl")
                ammeter_btn.setText("PicoAmeter...")
                ammeter_btn.openInNewWindow = True
                ammeter_btn.macros = "prefix=FARC:{}:{},carrier_prefix=FARC:{}:{},AREA={},UNIT={}".format(
                    self.macros()["AREA"],
                    self.macros()["POS"],
                    self.macros()["AREA"],
                    self.macros()["POS"],
                    self.macros()["AREA"],
                    self.macros()["IOC_UNIT"],)
            trig_btn = PyDMRelatedDisplayButton(filename="$PYDM/evnt/tprDiagNC.ui")
            trig_btn.setText("Triggers...")
            trig_btn.openInNewWindow = True
            print(self.macros()["CRATE"])
            if not(self.macros()["AREA"] == "LI11"):
                trig_btn.macros = "LOCA={},IOC_UNIT={},INST={},IOC={}, CPU={}, CRATE={}".format(
                    self.macros()["AREA"],
                    self.macros()["IOC_UNIT"],
                    0,
                    self.macros()["IOC"],
                    self.macros()["CPU"],
                    self.macros()["CRATE"])
            else:
                trig_btn.macros = "LOCA={},IOC_UNIT={},INST={},IOC={}, CPU={}, CRATE={}".format(
                    "IN10",
                    self.macros()["IOC_UNIT"],
                    0,
                    self.macros()["IOC"],
                    self.macros()["CPU"],
                    self.macros()["CRATE"])
           
            coef_btn = PyDMRelatedDisplayButton(filename="bcm_equation_params.ui")
            coef_btn.setText("Coefficients...")
            coef_btn.openInNewWindow = True
            coef_btn.macros = "PREFIX={}:{}:{}{}".format(
                self.type,
                self.macros()["AREA"],
                self.macros()["POS"],
                self.mad,
                self.sensor)            

        # Buttons only shown only if it is running in the SC accelerator
        if self.isSC:
            expert_btn = PyDMRelatedDisplayButton(filename="bcm_expert.py")
            expert_btn.setText("Expert...")
            expert_btn.openInNewWindow = True
            expert_btn.macros = "prefix={}:{}:{},carrier_prefix=AMCC:{}:{},MAD={},AREA={},UNIT={},IOC_UNIT{},IOC={},CPU,{},CRATE={},TYPE={}".format(
                    self.type,
                    self.macros()["AREA"],
                    self.macros()["POS"],
                    self.macros()["AREA"],
                    self.macros()["POS"],
                    self.macros()["INST"],
                    self.macros()["AREA"],
                    self.macros()["UNIT"],
                    self.macros()["IOC_UNIT"],
                    self.macros()["IOC"],
                    self.macros()["CPU"],
                    self.macros()["CRATE"],
                    self.type)

        help_btn = QPushButton("Help...")
        if self.isSC:
            help_btn.clicked.connect(self.open_bergoz_help)
        else:
            help_btn.clicked.connect(self.open_help)

        self.btn_layout.addStretch(10)

        # Button are only shown only if it is running in the SC accelerator
        if self.isSC:
            self.btn_layout.addWidget(expert_btn)
        else:
            if(not(self.type == "FARC")):
                self.btn_layout.addWidget(calb_btn)
            else:
                self.btn_layout.addWidget(ammeter_btn)
            self.btn_layout.addWidget(coef_btn)
            self.btn_layout.addWidget(trig_btn)
        self.btn_layout.addWidget(help_btn)
        self.main_layout.addLayout(self.btn_layout)

    def setup_plots(self):
        self.plot_layout = QHBoxLayout()
        self.weight_fn_layout = QHBoxLayout()
        self.wfp = BcmCalPlot(self.macros(), self.sensor, WaveformType.RAW)
        if self.isSC:
            self.wfp_sliders = BcmWeightFnSliderSC(macros=self.macros(),
                    parent=self, sensor=self.sensor)        
        else:
            self.wfp_sliders = BcmWeightFnSliders(macros=self.macros(),
                    parent=self, sensor=self.sensor)

        self.wfp.src_changed.connect(self.wfp_sliders.plot_src_changed)

        self.plot_layout.addWidget(self.wfp)
        self.weight_fn_layout.addWidget(self.wfp_sliders)

        self.main_layout.addLayout(self.weight_fn_layout)
        self.main_layout.addLayout(self.plot_layout)

    def open_help(self):
        dlg = QDialog(self)
        lo  = QVBoxLayout()

        lbl1 = QLabel("<b>Explanation of Pre, Middle, and Post Edges</b>")
        lbl1.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)

        lbl2 = QLabel("You use the pre and post regions to select the region "\
                      "where the signal is and the region where the background "\
                      "noise is. The reason for this is to subtract the noise "\
                      "from the signal. It is up to you to choose if you want "\
                      "to place the signal in the post or pre regions. The "\
                      "middle region provides a void area between the other regions. "\
                      "This area is ignored by the system. Use it if you need a "\
                      "distinct separation between the pre and post regions.")
        lbl2.setWordWrap(True)

        lbl3 = QLabel("The idea with the edges and coefficients is summarized by "\
                      "this formula:<br><br>"\
                      "sum(pre region) * CoefA0 + sum(post region) * CoefA1 + Offset<br>")
        lbl3.setWordWrap(True)

        lbl4 = QLabel("The pre and post regions selected using the sliders will "\
                      "be integrated separately. Coefficient A0 will be "\
                      "multiplied by the pre region and coefficient A1 will be "\
                      "multiplied by the post region. Both regions are finnaly "\
                      "summed up and the result is changed by an offset. You must "\
                      "choose opposite signals for A0 and A1 to make the noise "\
                      "be subtracted from the signal. Otherwise you will sum them up.")
        lbl4.setWordWrap(True)

        lbl5 = QLabel("Attention with the start of each region. The pre region "\
                      "starts at time 0, as well as the middle region. So, the "\
                      "pre and middle regions overlap with each other. If the "\
                      "middle region is smaller than the pre region, the system "\
                      "just ignores the middle region. The post region is"\
                      "different. It starts where the pre or middle region stops,"\
                      "whichever is bigger. This chart may make things more clear:")
        lbl5.setWordWrap(True)

        svg = QSvgWidget("help.svg", parent=dlg)
        lo.addWidget(lbl1)
        lo.addWidget(lbl2)
        lo.addWidget(lbl3)
        lo.addWidget(lbl4)
        lo.addWidget(lbl5)
        lo.addWidget(svg)

        dlg.setMinimumSize(600, 600)
        dlg.setLayout(lo)
        dlg.setWindowTitle("BCM Calibration Help")
        dlg.setModal(False)

        # if there's already a dialog open we should close it
        try:
            self.dlg.close()
        except:
            pass

        self.dlg = dlg
        self.dlg.show()


    def ui_filepath(self):
        return None
    
    
    def open_bergoz_help(self):
        dlg = QDialog(self)
        lo  = QVBoxLayout()

        lbl1 = QLabel("<b>Explanation of Averaging window</b>")
        lbl1.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)

        lbl2 = QLabel("The Bergoz chassis outputs a constant voltage level which"\
                      " the Bunch Charge Monitoring system converts into a measurement"\
                      " in pC. To operate, set the averaging window so that it does"\
                      " include the transition between voltage levels.")
        lbl2.setWordWrap(True)

        lo.addWidget(lbl1)
        lo.addWidget(lbl2)

        dlg.setMinimumSize(500, 200)
        dlg.setLayout(lo)
        dlg.setWindowTitle("BCM Help")
        dlg.setModal(False)

        # if there's already a dialog open we should close it
        try:
            self.dlg.close()
        except:
            pass

        self.dlg = dlg
        self.dlg.show()


    def ui_filepath(self):
        return None
