#!/usr/bin/python
# Face-image to whatever-data converter
import Image
import sys
import re

# Parse parameter
if len(sys.argv) < 2:
	print "Syntax: faceconv <filename.png>"
	print "writes output to filename.face"
	sys.exit()

infile = sys.argv[1]
outfile = re.sub("\.png", ".face", infile)
basename = re.sub("\.png", "", infile)

im = Image.open(infile)
out = file(outfile,"w")

# Sanity-check image dimensions
if im.size[1] != 312:
	print "Input image must be 312 pixels in y direction!"
	sys.exit()


out.write("; Offset data, converted from " + infile + ", 312 byte values.\n");
out.write("\txdef " + basename + "_data\n");
out.write("\tsection facedata,data_f\n");
out.write(basename + "_data:\n")

# Iterate through lines
for i in range(0,312):

	# Find first non-black pixel
	for j in range(0,im.size[0]):
		if(im.getpixel((j,i)) != (0,0,0) and im.getpixel((j,i)) != (0,0,0,255)):
			break
	
	# Output its offset
	out.write("\tdc.b " + str(j) + "\n")

print(infile + " converted successfully.")
