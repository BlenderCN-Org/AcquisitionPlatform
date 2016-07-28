function [c,r,l] = borrar(ball,varargin)

a= imfill(uint8(ball(:,:,1)>60&ball(:,:,2)<60));
a=bwlabel(a);
a(a>1)=0;
b= regionprops(a,{'centroid','boundingBox'});
c=b.Centroid;
r=sum(b.BoundingBox(3:4))/4; %+ 21
if(~isempty(varargin))
    if(strcmp(varargin{1},'radii') && length(varargin)==2)
        r= r+varargin{2};
    end
end

a= uint8(~(ball(:,:,1)>60&ball(:,:,2)<60));
b=bwlabel(a);
b(b==1)=0;

% 
% l= regionprops(b,{'centroid','Area','BoundingBox'});
% [~,i]=max([l.Area]);
% l=l(i);
% l.BoundingBox;
% l=l.Centroid;

l= regionprops(b,{'Area'});
[~,i]=max([l.Area]);
llum=ball(:,:,2).*uint8(b==i);
[x,y]=ind2sub(size(ball(:,:,2)),find(double(ball(:,:,2)==max(llum(:)))));
l=[mean(y) mean(x)];

if(~isempty(varargin))
    if(strcmp(varargin{1},'highlight_y') && length(varargin)==2)
        l=[mean(y) mean(x)+varargin{2}];
    elseif(strcmp(varargin{1},'highlight_x') && length(varargin)==2)
        l=[mean(y)+varargin{2} mean(x)];
    end
end