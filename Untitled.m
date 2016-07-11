


n= nikonController;
p=platform;
warning('off','all');
p.home();


stepVertical = -5;
stepHorizontal= 5;

for j=-5:stepVertical:-15
    p.move(p.deg2steps([0 stepVertical]));
    name= strcat('Images/Hassan/Domino_height_',num2str(j));
    for i=0:stepHorizontal:360
        imageName= strcat(name,'_step_',num2str(i),'.jpeg');
        image= n.capture();
        imwrite(image.Image,imageName);
        p.move(p.deg2steps([stepHorizontal 0]));
    end
    
end

warning('on','all');
n.delete
p.home()
p.delete