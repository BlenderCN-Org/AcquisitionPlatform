


n= nikonController;
p=platform;
warning('off','all');
p.home();

n.set('Image S',2);


stepHorizontal= 5;

stepVertical = 5;
for j=0:stepVertical:15
    p.move(p.deg2steps([0 j]),'Absolute');
    name= strcat('Images/Hassan/Domino_inclination_',num2str(j));
    for i=0:stepHorizontal:360
        p.move(p.deg2steps([i j]),'Absolute');
        imageName= strcat(name,'_step_',num2str(i),'.jpg');
        image= n.capture('exif',imageName);
    end
    
end

stepVertical = -5;
p.home()

for j=-5:stepVertical:-15
    p.move(p.deg2steps([0 j]),'Absolute');
    name= strcat('Images/Hassan/Domino_inclination_',num2str(j));
    for i=0:stepHorizontal:360
        p.move(p.deg2steps([i j]),'Absolute');
        imageName= strcat(name,'_step_',num2str(i),'.jpg');
        image= n.capture('exif',imageName);
    end
    
end




warning('on','all');
n.delete
p.home()
p.delete