from PIL import Image
from PIL.ExifTags import TAGS
import glob
import os

def get_exif(fn):
    ret = {}
    i = Image.open(fn)
    info = i._getexif()
    for tag, value in info.items():
        decoded = TAGS.get(tag, tag)
        ret[decoded] = value
    return ret

fileNames=[]
directory= "./calibrationImages/"

for f in os.listdir(directory):
    if (f.endswith(".jpg") or f.endswith(".JPG")):
        fileNames.append(f)

##############READING IMAGE INFORMATION FOR CLONING IN TO THE CAMERA OF BLENDER###############################
        
#the file frow which is reading could be random or whatever. Each file should have the same parameters.
exif_tags= get_exif(directory+fileNames[0])

focalLength= exif_tags["FocalLength"]
width= exif_tags["ExifImageWidth"]
height= exif_tags["ExifImageHeight"]

print focalLength[0]
print width
print height


###################READING INTRINSIC CAMERA PARAMETERS ################################


