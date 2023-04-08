%% Vehicle longtitudinal model parameter
Vehicle_mass = 15076; % vehicle total mass, kg
g = 9.81; % Gravity constant
Cr = 0.0085; % Rolling resistance constant
R_tire = 0.5; % Radius of the tire, m
 
A_front = 9.5; % Area of the front, m^2
Cd = 0.7963; % Aero drag coefficient
rho_air = 1.2; % Air density kg/m^3
 
FR = 1.18; % final drive gear ratio
% Ie = 1; % Inertia of engine
% Ig = 1; % inertia of generator
% Im = 1; % inertia of electrical motor
% Is = 1; % inertia of sun gear
% Ir = 1; % inertia of ring gear
% Ic = 1; % inertia of carrier gear
% Assuming inertia is 0
Ir = 0;   % ring gear inertia
Is = 0;   % sun gear inertia
Ic = 0;   % carrier gear inertia
Ns = 30;
Nr = 78;
m_inertia=0.0226; % (kg*m^2), rotor's rotational inertia
% Assuming 10 times inertia
m_inertia = m_inertia * 10;

%Np = 23;
k = Nr/Ns;
V_car = 10; %m/s
alpha = 0;% road angle
F_aero = 0.5*rho_air*A_front*Cd*V_car^2;
F_rolling = Vehicle_mass*g*Cr*cos(alpha);
F_friction = Vehicle_mass*g*sin(alpha);