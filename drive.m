cam = webcam(2);
preview(cam);
height=300;
width=300;
x=640/2-width/2;
y=480/2-height/2;

bboxes=[x y height width];
%Opens a new connection to a EV3 robot on a USB port 
myrobot = legoev3('usb');

% Create an object for left (port A) and right (port C) motors.
mL = motor(myrobot, 'A'); 
mR = motor(myrobot, 'C'); 

% Set the starting speed of the motors to 10% of the maximum power
mL.Speed = 15;
mR.Speed = 15;

% Opens a new connection to Ultrasonic Sensor on port 1.
rangeSensor = sonicSensor(myrobot, 1);
% Opens a new connection to Left Colour Sensor Sensor on port 2.
leftSensor = colorSensor(myrobot, 2);
% Opens a new connection to Right Colour Sensor on port 3.
rightSensor = colorSensor(myrobot, 3);

% Start left and right motors. 
start(mL);
start(mR);
BLACK = 40;
WHITE = 60;
distance = 0.04;
while true
    disp("running");
    % robot code come here
    % Measure the reflected light by reading the sensors in Active mode.
    LEFT = readLightIntensity(leftSensor,'reflected');
    % LEFT = LEFT - 10;
    RIGHT = readLightIntensity(rightSensor,'reflected');
    % Measure distance to an obstacle using the Ultrasonic Sensor
    distanceObstacle = readDistance(rangeSensor);
    disp(distanceObstacle);
    % If there is an obstacle brake and classify traffic sign in front
    % When the object is gone start motors again.
    if distanceObstacle < distance
        
        disp("object");
        stop(mL);
        stop(mR);
        
        label = 0;
        
        % usually max <= 0.5 happens when the robot doesn't stop immediately, making
        % the image taken blurry; hence we retake the image and plug again
        % into NN
        while(max(label) <= 0.5)
            pause(1);
            % take a snapshot, preprocess it and plug it into NN
            img = cam.snapshot;
            UI = insertObjectAnnotation(img,'rectangle',bboxes,'Processing Area');
            imshow(img);
            img_crop =imcrop(img,bboxes);
            im_crop = preprocess2(img_crop);
            label=net(im_crop');    
            drawnow;
        end
        % find index of max value and use a switch statement to decide what
        % to do based on it
        switch find(label>0.5)
            % left = turn left
            case 1 %left
                LEFT = readLightIntensity(leftSensor,'reflected');
                disp("left");
                while(LEFT < BLACK)
                    start(mR);
                    mR.Speed = 15;
                    stop(mL);
                    LEFT = readLightIntensity(leftSensor,'reflected');
                    disp("left:" + LEFT);
                    pause(1);
                end
            % right = turn right
            case 2 %right
                disp("right");
                RIGHT = readLightIntensity(rightSensor,'reflected');
                while(RIGHT < BLACK)
                    start(mL);
                    mL.Speed = 15;
                    stop(mR);
                    RIGHT = readLightIntensity(rightSensor,'reflected');
                    disp("right:" + RIGHT);
                    pause(1);
                end
            % stop = stop the car for 5 seconds and then move on
            case 3 %Stop
                disp("stop");
                stop(mL, 1);
                stop(mR, 1);
                pause(5);
            % park = stop the car and break the movement loop
            case 4 %park
                disp("park");
                stop(mL, 1);
                stop(mR, 1);
                break;
        end
        
        % if the object(sign) has not been moved yet, stay still
        while(distanceObstacle < distance + 0.05)
             distanceObstacle = readDistance(rangeSensor);
        end

        start(mL);
        start(mR);
        mL.Speed = 15;
        mR.Speed = 15;

    else 
        start(mL);
        start(mR);
        mL.Speed = 15;
        mR.Speed = 15;

    end 

    %end of robot code 
    %disp(“thank you Geoffrey”);
    
end