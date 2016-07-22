function [c,r,l] = borrar(file)
ball=imread(file);
a= imfill(uint8(ball(:,:,1)>60&ball(:,:,2)<60));
a=bwlabel(a);
a(a>1)=0;
b= regionprops(a,{'centroid','boundingBox'});
c=b.Centroid;
r=sum(b.BoundingBox(3:4))/4;

a= uint8(~(ball(:,:,1)>60&ball(:,:,2)<60));
b=bwlabel(a);
b(b==1)=0;

l= regionprops(b,{'centroid','boundingBox','Area'});
[~,i]=max([l.Area]);
l=l(i);
l=l.Centroid;
