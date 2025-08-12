TOP=..

include $(TOP)/configure/CONFIG

install:
	/usr/bin/python ./scripts/expandChain.py  chain.xml > scanner.xml
	/usr/bin/python ./scripts/maketemplate.py -b xml -d EK1101 -r 0x00120000 -o ../bcmApp/Db/EK1101.template
	/usr/bin/python ./scripts/maketemplate.py -b xml -d EL3202-0010 -r 0x0016000A -o ../bcmApp/Db/EL3202-0010.template

clean:
	rm -f scanner.xml
	rm -f EL3202-0010.template
distclean: clean
realclean: clean
uninstall:
