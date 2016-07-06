%% Compile.m
%% Use this to compile NikonController for 64 bits matlab. 
%% The output mex is at the Nikon Subfolder (../Nikon)

Outputpath = '../';
mex -largeArrayDims nikonController_mex.cpp NikonManager.cpp Function.cpp Callback.cpp Winmm.lib jpeg/jpeg.lib libraw/libraw.lib;
movefile('nikonController_mex.mexw64',Outputpath);