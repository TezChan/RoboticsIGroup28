clc
close all
clear all

global scale dobot omni

% Factor to scale the workspace of the Phantom Omni to the Dobot
scale = 1.5;

% Initialize the Dobot and Phantom Omni
omni = RobotRaconteur.Connect('tcp://127.0.0.1:5150/PhantomOmniSimulinkHost/PhantomOmni')
dobot = RobotRaconteur.Connect('tcp://localhost:10001/dobotRR/dobotController')

q = omni.ActualJointAngles;
q = q(1:3);
P0T_omniORIGINAL = OmniForwardKinematics(q)

angles = GetDobotAngles(dobot)';
P0T_dobotINIT = DobotForwardKinematics(angles);
    
setPosition(P0T_dobotINIT+[0;-50;100],P0T_dobotINIT)
pause(2)
setPosition(P0T_dobotINIT,P0T_dobotINIT)

% ========================================================================
% TODO - Raise Dobot to get a picture of the paper and setup boundary
% ========================================================================

dobotx = zeros(20,1);
doboty = zeros(20,1);
omnix = zeros(20,1);
omniy = zeros(20,1);
for i = 1:20
%     % Get Phantom Omni initial position to compare against
%     q = omni.ActualJointAngles;
%     q = q(1:3);
%     P0T_omniINIT = OmniForwardKinematics(q);
%     
%     % Pause to allow for movement of the Phantom Omni
    pause(1)
    
    % Get the new position of the Phantom Omni
    q = omni.ActualJointAngles;
    q = q(1:3);
    P0T_omniFIN = OmniForwardKinematics(q);
    P0T_omniFIN(1) = -P0T_omniFIN(1);
    P0T_omniFIN(3) = 0;
    
    omnix(i) = P0T_omniFIN(1);
    omniy(i) = P0T_omniFIN(2);
    
    % ========================================================================
    % TODO - Send torque to phantom omni if dobot will go outside the boundary
    % ========================================================================
    
        
    % Send new position to Dobot
    angles = GetDobotAngles(dobot)';
    P0T_dobotINIT = DobotForwardKinematics(angles);
    
    dobotx(i) = P0T_dobotINIT(1);
    doboty(i) = P0T_dobotINIT(2);
    
    setPosition(P0T_omniFIN,P0T_dobotINIT)
end

hold on
plot(dobotx, doboty, 'red')
plot(omnix, omniy, 'blue')

title('Comparison between Dobot and Omni positions')
legend('Dobot','Omni')
xlabel('x position (mm)')
ylabel('y position (mm)')