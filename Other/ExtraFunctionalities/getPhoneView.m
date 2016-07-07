function getPhoneView( varargin )
%GETPHONEVIEW Function to get images from the phone. Close the figure when
%you are done.
%---PARAMETERS
%-------0 INPUT: ip default used. (May not work for most of the cases!)
%-------1 INPUT: string containing the ip where the images are being send.

    url= 'http://';
    if(isempty(varargin))
        url= strcat(url,'192.168.11.82:8080');
    end

    if(length(varargin) == 1)
        url= strcat(url,varargin{1});
    end
    
    url= strcat(url,'/shot.jpg');
    
    im= imread(url);
    figure= image(im);
    
    while(ishandle(figure))
        im=imread(url);
        set(figure,'CData',im);
        drawnow;
    end
end

