function [meanErr,files,err,sample] = evaluateImages(varargin)
%EVALUATEIMAGES Function to evaluate the images of the lights

    directoryImages= 'lightPoint2/';
    files= dir(strcat(directoryImages,'*.jpg'));

    count= size(files,1);
    err= [];

    limitAngle= 90;
    nSteps= 20;
    sample= zeros(nSteps+1,nSteps+1);

    azimuth=[];
    inclination= []
    stepAngle= 90/nSteps*2;
    
    for i=0:nSteps
        azimuth=[azimuth -limitAngle+stepAngle*i];
        inclination= [inclination stepAngle*i];
    end

    
    for i=1:count
        image= imread(strcat(directoryImages,files(i).name));
        realMeasures= sscanf(files(i).name,'Azimuth_%f_Inclination_%f_x_%f_y_%f_z_%f.jpg');
        u= [realMeasures(3) realMeasures(4) realMeasures(5)]; 
        [~,e]= lightDirections(image,[],0,'Auto',u,1000,'Background');
        x= find(azimuth==realMeasures(1));
        y= find(inclination==realMeasures(2));
        sample(y,x)=e;
        err= [err e]
    end

meanErr= mean(err);
end

