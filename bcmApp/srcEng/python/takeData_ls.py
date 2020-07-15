#!python

from pycpsw import *
import sys
import os
import datetime
import shutil
import time
import getopt
import signal

class StreamHandler:

	def __init__(self, directory, name, root, size, timeout=3000000):
		self.strm = Stream.create(root.findByName(name))
		self.buf = memoryview(bytearray(size * 4))
		self.timeout = timeout
		self.directory = directory
		self.name = name
		self.count = 0

	def openFile(self):
		self.file = open(self.directory + self.name + ".bin", "w")

	def closeFile(self):
		self.file.close()

	def readStream(self):
        with self.strm as strm:
            nelms = strm.read(self.buf, self.timeout)
            if nelms == 0:
                print("Warning: 0 bytes read on %s" % self.name)
            else:
                # remove header and write data to file (2x 32-bit words)
                self.file.write(self.buf[8:])

            self.count += 1

class TriggerHanlder:

	def __init__(self, root):
		self.triggerCmd            = Command.create(root.findByName("/AppTop/DaqMuxV2[0]/TriggerDaq"))
		self.initCmd               = Command.create(root.findByName("/AmcCarrierCore/AmcCarrierBsa/BsaWaveformEngine/WaveformEngineBuffers/Initialize"))
		self.armHWTriggerCmd       = Command.create(root.findByName("/AppTop/DaqMuxV2/ArmHwTrigger"))
		self.triggerHwAutoRearmVal = ScalVal.create(root.findByName("/AppTop/DaqMuxV2/TriggerHwAutoRearm"))

	def trigger(self):
		self.triggerCmd.execute()

	def init(self):
		self.initCmd.execute()

	def armHwTrigger(self):
		self.armHWTriggerCmd.execute()

	def setHwAutoream(self):
		self.triggerHwAutoRearmVal.setVal([1, 1])

	def resetHwAutoream(self):
		self.triggerHwAutoRearmVal.setVal([0, 0])

class BufferHanlder:

	def __init__(self, root):
		self.endAddr       = ScalVal.create(root.findByName("/AmcCarrierCore/AmcCarrierBsa/BsaWaveformEngine/WaveformEngineBuffers/EndAddr"))
		self.startAddr     = ScalVal.create(root.findByName("/AmcCarrierCore/AmcCarrierBsa/BsaWaveformEngine/WaveformEngineBuffers/StartAddr"))
		self.daqBufferSize = ScalVal.create(root.findByName("/AppTop/DaqMuxV2/DataBufferSize"))
		self.initCmd       = Command.create(root.findByName("/AmcCarrierCore/AmcCarrierBsa/BsaWaveformEngine/WaveformEngineBuffers/Initialize"))

	def setSize(self, size, strm_num):
		sAddr = [0x80000000, 0x90000000, 0xA0000000, 0xB0000000, 0xC0000000, 0xD0000000, 0xE0000000, 0xF0000000]
        eAddr = [addr + 4 * size for addr in sAddr]
		self.endAddr.setVal(eAddr[strm_num])
		self.startAddr.setVal(sAddr[strm_num])
		self.daqBufferSize.setVal([size, size])
		self.initCmd.execute()

def usage(name):
	print("Usage: %s [-h] [-Y|--yaml yaml_file] [-D|--defaults defaults_file] [-d|--data data_directory ] [-s|size samples] [-n|--shots shots] [-t|--time time]" % name)
	print("    -h                          : show this message")
	print("    -Y|--yaml yaml_file         : yaml definition file")
	print("    -D|--defaults defaults_file : defaults file (yaml). If defined, the defaults will be loaded.")
	print("    -d|--data data_directory    : directory where data will be saved")
	print("  Acquisition parameters:")
	print("    -b|--bay bay_number         : bay number to read from (0: bay 0, 1: bay 1, 2: both) (default = 1)")
	print("    -s|--size samples           : number of samples (default = 1000).")
	print("    -n|--shots shots            : number of shots to take (default = 1)")
	print("    -t|--time time              : time in seconds between shots (default = 0). Only use with software triggers")
	print("  Trigger parameters:")
	print("    -H|--HwTrigger              : Use hadrware trigger. If not set (default), software trigger will be used")
	print("")

def main(argv):
	topDev       = "NetIODev"
	numSamples   = 1000
	numShots     = 1
	timeShots    = 0
	useHwTrigger = False
	yamlFile     = ""
	dataDir      = ""
	yamlConfig   = ""
	bayNumber    = 1

	try:
		opts, args = getopt.getopt(argv,"hY:D:d:b:s:n:t:H",["yaml=", "defaults=", "data=", "bay=", "size=", "shots=", "time=", "HwTrigger"])
	except getopt.GetoptError:
		usage(sys.argv[0])
		sys.exit(2)

	for opt, arg in opts:
		if opt in ("-h","--help"):
			usage(sys.argv[0])
			sys.exit()
		elif opt in ("-Y","--yaml"):    	# Yaml definition file
			yamlFile = arg
		elif opt in ("-D", "--defaults"):	# Defaults file
			yamlConfig = arg
		elif opt in ("-d", "--data"):		# Data directory
			dataDir = arg
		elif opt in ("-b", "--bay"):		# Bay number
			try:
				bayNumber = int(arg)
			except:
				pass
		elif opt in ("-s","--size"):		# Number of samples
			try:
				numSamples = int(arg)
			except:
				pass
		elif opt in ("-n", "--shots"):		# Number of shots
			try:
				numShots = int(arg)
			except:
				pass
		elif opt in ("-t", "--time"):		# Time between shots
			try:
				timeShots = int(arg)
			except:
				pass
		elif opt in ("-H", "--HwTrigger"):	# Select Hardware triggers
			useHwTrigger = True

	if not os.path.isfile(yamlFile):
		print("Yaml file not defined or doesn't exist!")
		print("")
		sys.exit(2)

	if not os.path.exists(dataDir):
		print("Data directory not defined or doesn't exist!")
		print("")
		sys.exit(2)

	if ((bayNumber < 0) or (bayNumber > 2)):
		print("Wrong bay number selected! Valid options are 0, 1 or 2")
		print("")
		sys.exit(2)

	# Set the stream indexes according to the bay number 
	streamBegin = 0
	streamEnd = 8
	if (bayNumber == 0):
		streamEnd = 4
	elif (bayNumber == 1):
		streamBegin = 4

	# Load YAML definitions
	print("\nLoading YAML definition...")
	root = Path.loadYamlFile(yamlFile, topDev);
	mmio = root.findByName("mmio")

	if os.path.isfile(yamlConfig):
		print("")
		print("Loading defaults...")
		mmio.loadConfigFromYamlFile( yamlConfig )

	# Create working directory
	directory = dataDir + datetime.datetime.now().strftime("%Y%m%d-%H%M%S") + "/"
	print("Creating base directory %s" % directory)
	try:
		os.mkdir( directory )
	except OSError, e:
		if e.errno != 17:
			raise  # This was not a "directory exist" error...

	# Create handlers
	print("Creating hanlders...")
	bh = BufferHanlder(mmio)
	th = TriggerHanlder(mmio)
	sh = []
	#for i in range(streamBegin, streamEnd):
	for i in (streamBegin, streamEnd-1):
		sh.append(StreamHandler(directory, "Stream" + str(i), root, numSamples))

	# Set the buffer size
	print("Settiing buffer size...")
	bh.setSize(numSamples, 0)

	if useHwTrigger:
		th.armHwTrigger()
		th.setHwAutoream()

	# Open files
	print("Opening files...")
	for s in sh:
		s.openFile()

	# Start taking data
	print("Starting data acquisition...")

	for i in range(numShots):
		th.init()

		if not useHwTrigger:
			th.trigger()

		for s in sh:
			s.readStream()

		if not useHwTrigger:
			time.sleep(timeShots)

	# Close files
	print("Closing files...")
	for s in sh:
		s.closeFile()

	if useHwTrigger:
		th.resetHwAutoream()

	print("\nDone!")
	print("Shots taken: %d" % numShots)
	print("Samples per shot: %d" % numSamples)
	if (bayNumber == 2):
		print("From both bays")
	else:
		print("From bay: %d" % bayNumber)
	if useHwTrigger:
		print("Using hardware triggers")
	else:
		print("Using software triggers")
		print("Time between shots: %d seconds" % timeShots)
	print("Files written to: %s" % directory)
	print("")

if __name__ == "__main__":
	main(sys.argv[1:])
