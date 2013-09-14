#!/usr/bin/python2
#  should now work on python3. Of course that requires having the image lib.
# Face-image to whatever-data converter
# v2 - output offsets relative to 32... or something. (:
import Image
import sys
import re

# Parse parameter
if len(sys.argv) < 2:
	print("Syntax: faceconv <filename.png>")
	print("writes output to filename.face")
	sys.exit()

infile = sys.argv[1]
outfile = re.sub("\.png", ".face", infile)
basename = re.sub("\.png", "", infile)

im = Image.open(infile)
out = file(outfile,"w")

# Sanity-check image dimensions
# yeah fuck that (:
#if im.size[1] != 312:
#	print("Input image must be 312 pixels in y direction!");
#	sys.exit()


out.write("; Offset data, converted from " + infile + ", 312 byte values.\n");
out.write("\txdef " + basename + "_data\n");
out.write("\tsection facedata,data_f\n");
out.write(basename + "_data:\n")

# Iterate through lines
for i in range(0, im.size[1]):

	# Find first non-black pixel
	for j in range(0,im.size[0]):
		pixie = im.getpixel((j,i))

# with 1 bit images, either use 1 or 0, depending on whether it is white
# or black. Yes, this is a cheap tool (:

		if(pixie != (0,0,0) and pixie != (0,0,0,255) and pixie != 1):
			break
# offset in triangle - 32 is 1 pixel, 0 is 32 solid pixels. 8 is 24 solid, etc.
# offset from top of bitmap.
	j/=4
	j = 64 - j


	# Output its offset
	out.write("\tdc.b " + str(j) + "\n")

print(infile + " converted successfully.")
