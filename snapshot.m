%set the height and width of the bounding box
height=300;
width=300;
%set the origin of the bounding box
x=640/2-width/2;
y=480/2-height/2;


%define the bounding box
bboxes=[x y height width];
%take 150 snapshots
for i = 1:150
    disp(i);
    %take a snapshot. C is a camera.
    img=c.snapshot;
    %set a bounding box
    target = insertObjectAnnotation(img,'rectangle',bboxes,'Processing Area');
    %crop image to the bounding box
    cropped=imcrop(img,bboxes);
    %resize the cropped image
    resized = imresize(cropped, [120 120]);
    %show the bounding box
    imshow(target);
    %keep the bounding box
    drawnow;
    pause(3);
    %save the image in a bmp file
    imwrite(resized, i +".bmp");
end