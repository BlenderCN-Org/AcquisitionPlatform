function [outputImage] = readNef(pathImage, varargin)
%readNef use this function to read Nef from files. 
%DEFAULT SETTINGS:
%   -White Balance: 'On'. (Does apply white balance). 
%   -intensityMultiplier= 4. (Conversion from 14 bits to 16)
%   -demosaic: Does not demosaic (bayer pattern values returned)
%   -exif: Does not return exif. Anyways, the exif is needed for white balance
%   calculation, so if the white balance is 'on', the exif will be
%   returned.
%
%SOME EXAMPLES:
%   image= readNef('image.nef','White Balance','off') --> returns the bayer
%   pattern values without the white balance correction.
%
%   image= readNef('image.nef','W',[3.2134,1.54343]) --> returns the
%   bayer pattern values with the white balance indicated.
%
%   image= readNef('image.nef','w','off',demosaic','exif') --> returns the image
%   MxNx3 already demosaiced, without the white balance aplied, along with the
%   exif file. 
%
%   image= readNef('image.nef','d','e') --> returns the image
%   MxNx3 already demosaiced, with the white balance aplied, along with the
%   exif file. 
%
%   image= readNef('image.nef','d','e','i',1) --> returns the image
%   MxNx3 already demosaiced, with the white balance aplied, along with the
%   exif file, without an intensity adjustement of 1 (no conversion from 14
%   bits to 16 is done).

validInputs= {'White Balance','Demosaic','Exif','Intensity Multiplier'};

intensityMultiplier = 3; %this multiplier is for doing the conversion from 14 to 16 bits. 
%(Nef files are 14 bits, and images of 16 bits are returned, so there has 
% be some conversion)

whiteBalance= true;
whiteBalancePoint= false;
demosaicImage= false;

exif= false;
WBfactors= [];

nInputs= length(varargin);
skipIteration= false;
for i=1:nInputs
    if(~skipIteration)
        input= validatestring(varargin{i},validInputs);
        if (strcmp('White Balance',input))
            if(i+1>nInputs)
                error('Please indicate a value for the White Balance');
            end
            if(ischar(varargin{i+1}))
                if(strcmp(varargin{i+1},'on'))
                    whiteBalance= true;
                elseif(strcmp(varargin{i+1},'off'))
                    whiteBalance= false;
                elseif(strcmp(varargin{i+1},'reference'))
                    whiteBalancePoint=true;
                    whiteBalance=false;
                else
                    error('The value of White Balance should be ''on'' or ''off''');
                end
            elseif(isnumeric(varargin{i+1}))
                WBfactors= varargin{i+1};
                if(length(WBfactors)<2 || length(WBfactors)>4)
                    error('The length of the array of custom White Balance should be ranging from 2 to 4. The order should be: R,B,G1,G2');
                end
            end
            skipIteration= true;
        elseif(strcmp('Demosaic',input))
            demosaicImage= true;
        elseif(strcmp('Exif',input))
            exif= true;
        elseif(strcmp('Intensity Multiplier',input))
            if(i+1>nInputs)
                error('Please indicate a value for the Intensity Multiplier');
            end 
            if(~isnumeric(varargin{i+1}))
                error('The intensity multiplier must be a number');
            end
            intensityMultiplier= varargin{i+1};
            skipIteration= true;
        end
    else
        skipIteration= false;
    end
end

if(exif || whiteBalance)
    image= mex_readNef(pathImage,'exif');
else
    image= mex_readNef(pathImage);
end

if(whiteBalance)
    listParameters= strsplit(image.Exif);
    [found,index]= ismember('WB_RBLevels',listParameters);
    if(found)
        WBfactors(1)=str2double(listParameters{index+2});
        WBfactors(2)=str2double(listParameters{index+3});
        WBfactors(3)=str2double(listParameters{index+4});
        WBfactors(4)=str2double(listParameters{index+5});
    else
        error('The white balance parameters was not found in the exif');
    end
end

image.Image= image.Image*intensityMultiplier;

if(~isempty(WBfactors))
    image.Image(1:2:end,1:2:end)=image.Image(1:2:end,1:2:end)*WBfactors(1);
    image.Image(2:2:end,2:2:end)=image.Image(2:2:end,2:2:end)*WBfactors(2);
    if(length(WBfactors)>=3)
        image.Image(2:2:end,1:2:end)=image.Image(2:2:end,1:2:end)*WBfactors(3);
    end
    if(length(WBfactors) ==4)
        image.Image(1:2:end,2:2:end)=image.Image(1:2:end,2:2:end)*WBfactors(4);
    end
end

%scale= (2^16-1)/max(image.Image(:));
%image.Image= image.Image*scale;
image.Image= image.Image*intensityMultiplier;


if(demosaicImage)
    image.Image= demosaic(image.Image,'rggb'); 
end

if(whiteBalancePoint)
    disp('Select the point in the image you want to use as white reference');
    imshow(image.Image);
    [x,y]= getpts;
    x= round(x);
    y= round(y);
    redBalance= image.Image(y,x,2)/image.Image(y,x,1);
    blueBalance= image.Image(y,x,2)/image.Image(y,x,3);
    image.Image(:,:,1)= image.Image(:,:,1)*redBalance;
    image.Image(:,:,3)= image.Image(:,:,3)*blueBalance;
    close all
    imshow(image.Image);
end


outputImage= image;

end

