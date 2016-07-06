%10/06/216
%In this file some examples of basic usage of the wraper will be shown. 
%



%initializate camera, not setting default parameters. 
nikon= nikonController;

%delete nikon camera. As only one camera can be controlled, be sure of
%deleting the camera before creating a new handle. Otherwise, matlab can
%crash badly.
nikon.delete;

%initializate camera, setting default parameters to the values stored in
%defaultParemeters.mat
nikon= nikonController('default');
nikon.delete; nikon= nikonController;

%see all the parameters values.
a= nikon.get()

%see the range of all the posibles values.
nikon.range()

%set aperture value to the third possible value.
nikon.set('Aperture', 3);

%capture a picture, and save it in image 
image = nikon.capture();

%return camera parameters to the default values. 
nikon.setDefault();

%check the values changed
nikon.get()

%set the compression level to shoot 2 images at the same time(RAW+ JPEG)
nikon.set('Compression Level', 5);

%get a raw and jpeg image at the same time.
[raw, jpeg] = nikon.capture();


%show liveView
nikon.liveView()

%save the current camera parameters as the default ones
nikon.changeDefault()


%close the current conection with the camera.
nikon.delete()
