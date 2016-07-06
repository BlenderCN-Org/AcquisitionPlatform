llum=3;

cieplot()


gamut=[0.675 0.322; 0.409 0.518; 0.167 0.04];
g=[gamut; gamut(1,:)];
pas=0.02;
[x y]=meshgrid(0:pas:1,0:pas:1);
xf=fliplr(x);
yf=fliplr(y);
x(1:2:end,:) = xf(1:2:end,:);
y(1:2:end,:) = yf(1:2:end,:);
x=x';
y=y';
in=inpolygon(x(:),y(:),g(:,1),g(:,2));
x=x(in);
y=y(in);

Llums(llum,'on')
Llums(llum,255)
h=[];
for i=1:numel(x)
    delete(h);
    h = plot(x(i),y(i), '+k');
    drawnow;
    Llums(llum,[x(i) y(i)]);
    pause(0.1);
end
delete(h)
Llums(llum,'off')
    
