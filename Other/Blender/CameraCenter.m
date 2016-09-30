function out = CameraCenter(cameraParams,ind)

    [rotationMatrices, translationVectors] = getRotationAndTranslation(cameraParams);
    out = rotateAndShiftCam([0 0 0]',rotationMatrices(:,:,ind)', translationVectors(ind,:)');
end
%--------------------------------------------------------------------------
    function [rotationMatrices, translationVectors] = ...
            getRotationAndTranslation(cameraParams)
        isStereo = isa(cameraParams, 'stereoParameters');
        if isStereo
            rotationMatrices = cameraParams.CameraParameters1.RotationMatrices;
            translationVectors = cameraParams.CameraParameters1.TranslationVectors;
        else
            rotationMatrices = cameraParams.RotationMatrices;
            translationVectors = cameraParams.TranslationVectors;
        end
    end

%--------------------------------------------------------------------------
    function camPts = rotateAndShiftCam(camPts,rot, tran)        
        
        % since we swapped the camera and the board, apply the 
        % transformation backwards: first we translate, then we rotate in
        % the opposite direction (take transpose of the rotation matrix) so
        % that the relative positioning of the camera with respect to the
        % board remains the same while the board is placed at an origin
        rot = rot';
       
        camPts  = rot*bsxfun(@minus, camPts, tran);                
    end
        

