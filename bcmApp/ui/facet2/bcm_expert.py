import os
from pydm import Display

class BCMExpert(Display):

    def __init__(self, parent=None, args=None, macros=None):
        super(BCMExpert, self).__init__(parent=parent, args=args, macros=macros)
        self.setup_plots()

    def setup_plots(self):
        self.ui.wfpRawPlusWeight.plotItem.setLabels(
        left="ADC counts",
        bottom="nanoseconds")

    def ui_filename(self):
        return "bcm_expert.ui"

    def ui_filepath(self):
        ui_path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(ui_path, self.ui_filename())
