function [outputImage] = readNef(pathImage, varargin)
%readNef Read .nef image information and process it in to an image. The
%output depends on the settings entered. The default settings are the
%following:
%
%DEFAULT SETTINGS:
%   -White Balance: 'On'. (Does apply white balance).
%           -Possible values: 'on','off','reference',[RedBalance
%           BlueBalance], [RedBalance BlueBalance Green1Balance],
%           [RedBalance BlueBalance Green1Balance Green2Balance].
%   -intensityMultiplier= 4. (Conversion from 14 bits to 16 has to be done)
%           -Possible values: Any number
%   -demosaic: 'on' Does demosaic.
%           -Possible values: 'on','off'
%   -exif: Does return exif. Anyways, the exif is needed for white balance
%   calculation, so if the white balance is 'on', the exif will always be
%   returned.
%
%SOME EXAMPLES:
%   image= readNef('image.nef','White Balance','off') --> returns the image
%   MxNx3 already demosaiced but without the auto white balance correction.
%
%   image= readNef('image.nef','W',[3.2134,1.54343]) --> returns the
%   image MxNx3 already demosaiced with the red balance and blue balance
%   indicated.
%
%   image= readNef('image.nef','w','off',demosaic','off','exif') --> 
%   returns the image MxN non demosaiced, without the white balance 
%   aplied, along with the exif file. 
%
%   image= readNef('image.nef','i',12) --> returns the image
%   MxNx3 already demosaiced, with the auto white balance aplied, along 
%   with the exif file, with an intensity scale of 12.
%
%   image= readNef('image.nef','i',1) --> returns the image
%   MxNx3 already demosaiced, with the white balance aplied, along with the
%   exif file, with an intensity adjustement of 1 (no conversion from 14
%   bits to 16 is done).

validInputs= {'White Balance','Demosaic','Exif','Intensity Multiplier'};

intensityMultiplier = 4; %this multiplier is for doing the conversion from 14 to 16 bits. 
%(Nef files are 14 bits, and images of 16 bits are returned, so there has 
% be some conversion)

autoWhiteBalance= true;
whiteBalancePoint= false;
demosaicImage= true;

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
                    autoWhiteBalance= true;
                elseif(strcmp(varargin{i+1},'off'))
                    autoWhiteBalance= false;
                elseif(strcmp(varargin{i+1},'reference'))
                    whiteBalancePoint=true;
                    autoWhiteBalance=false;
                else
                    error('The value of White Balance should be ''on'' or ''off''');
                end
            elseif(isnumeric(varargin{i+1}))
                autoWhiteBalance= false;
                WBfactors= varargin{i+1};
                if(length(WBfactors)<2 || length(WBfactors)>4)
                    error('The length of the array of custom White Balance should be ranging from 2 to 4. The order should be: R,B,G1,G2');
                end
            end
            skipIteration= true;
        elseif(strcmp('Demosaic',input))
            demosaicImage= true;
            if(ischar(varargin{i+1}))
                if(strcmp(varargin{i+1},'on'))
                    demosaicImage= true;
                elseif(strcmp(varargin{i+1},'off'))
                    demosaicImage= false;
                else
                    error('The value of demosaic should be ''on'' or ''off''');
                end
            end
            skipIteration=true;
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

if(exif || autoWhiteBalance)
    image= mex_readNef(pathImage,'exif');
    listParameters= strsplit(image.Exif);
    [found,index]= ismember('ISO',listParameters);
    if(found)
        isoValue= str2double(listParameters{index+2});
        if(isoValue >= 800)
            warning('The image was taken with an ISO of %d (Too High). This could produce noisy images, so consider a lower ISO.',isoValue);
        end
    end
else
    image= mex_readNef(pathImage);
end

if(autoWhiteBalance)
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

if(demosaicImage)
    image.Image= double(demosaic(image.Image,'rggb')); 
end

if(whiteBalancePoint)
    if(~demosaicImage)
        image.Image= double(demosaic(image.Image,'rggb'));
    end
    disp('Select the point in the image you want to use as white reference');
    imshow(image.Image);
    [x,y]= getpts;
    x= round(x);
    y= round(y);
    %OPTION1: Scale with respect the green value
    redBalance= (double(image.Image(y,x,2))/double(image.Image(y,x,1)));
    blueBalance= (double(image.Image(y,x,2))/double(image.Image(y,x,3)));
    greenBalance=1;

    image.Image(:,:,1)= image.Image(:,:,1)*redBalance;
    image.Image(:,:,2)= image.Image(:,:,2)*redBalance;
    image.Image(:,:,3)= image.Image(:,:,3)*redBalance;
    
    close all
    imshow(image.Image);
end

if(demosaicImage)
    image.Image = image.Image/max(image.Image(:));
end    
outputImage= image;

end

