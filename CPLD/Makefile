
DESIGN = sdmapper
DEVICE = XC95144XL-10-TQ100
UCF_FILE = src/pinout_final.ucf

# Make all runs to place & route
all : bitstream

# bitstream : Creates device bitstream
bitstream : ${DESIGN}.jed

# translate: Stops after full design elaboration for analysis and floorplanning prior to place and route step
translate : ${DESIGN}.ngd

# Following executes the ISE run

# Produces: .lso .ngc .ngr .srp *_xst.xrpt _xmsgs/
${DESIGN}.ngc: ${DESIGN}.xst
	xst -intstyle ise -ifn $<

# Produces: .bld .ngd *_ngdbuild.xrpt _xmsgs/ xlnx_auto_0_xdb/ 
${DESIGN}.ngd : ${DESIGN}.ngc ${UCF_FILE}
	ngdbuild -intstyle ise -uc ${UCF_FILE} -p ${DEVICE} ${DESIGN}.ngc $@

# Produces: .mfd .pad .pnx .rpt .vm6 .xml _build.xml _pad.csv _html/ _xmsgs/
${DESIGN}.vm6 : ${DESIGN}.ngd
	cpldfit -intstyle ise -p ${DEVICE} -ofmt vhdl -optimize density -htmlrpt -loc on -slew fast -init low -inputs 54 -pterms 90 -unused float -power std -terminate keeper $?
	XSLTProcess ${DESIGN}_build.xml

# produces .nga
${DESIGN}.nga: ${DESING}.vm6
	tsim -intstyle ise ${DESIGN} $@

# Produces _xmsgs/ .jed
${DESIGN}.jed: ${DESIGN}.vm6
	hprep6 -s IEEE1149 -n ${DESIGN} -i ${DESIGN}
	mv $@ ${DESIGN}_${VERSION}.jed

# Clean up all the files from the Vivado run
clean:
	rm -rf *.ngd *.bit *.map *.bld *.xml *.html *.jed *.nga *.err \
	*.xrpt *.txt *.pad *.csv xlnx_auto* _xmsgs *.lso *_html *.xml \
	*.ngc *.ngr *.srp *.lst *.gyd *.mfd *.pnx *.rpt *.vm6

# Tar and compress all the files
tar:
	tar -czvf ${DESIGN}.tar.gz *.ipf *.xsl *.prj *.svf *.xise *.xst *.xsvf Makefile
