
import bpy
from math import *
import mathutils
import time
numberOfImages= 30
step= 2*pi/numberOfImages

light = bpy.data.objects["Point"]

vec= mathutils.Vector((1.0,1.0,1.0))

#init distance of rotation to the y position of the light
radiiRotation= light.location[1];

angle= 0

for image in range(0,numberOfImages+1):
    angle= image*step
    xPosition= sin(angle)*radiiRotation
    yPosition= cos(angle)*radiiRotation

    
    newPosition= mathutils.Vector((xPosition,yPosition,0.0))
    light.location= newPosition
    
    bpy.ops.wm.redraw_timer(type='DRAW_WIN_SWAP', iterations=1)
    bpy.context.scene.update()
    
    directory= ''

    bpy.data.scenes["Scene"].render.filepath = 'C:/Users/vmoyano/Documents/GitHub/AcquisitionPlatform/Other/ExtraFunctionalities/renderedImages/lightPoint/Image%d_LightVector__x_%f_y_%f_z_%f.jpg' % (image, xPosition, -yPosition, 0.00)
    bpy.ops.render.render( write_still=True )
    