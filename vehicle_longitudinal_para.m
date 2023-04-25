

% global Vehicle_mass g Cr R_tire A_front rho_air Cd FR 
% Vehicle Parameters
Vehicle_mass = 6273; % vehicle total mass, kg
g = 9.81; % Gravity constant
Cr = 0.009; % Rolling resistance constant
R_tire = 0.74; % Radius of the tire, m
FD_ratio = 4.56; %final drive ratio
A_front = 8.18; % Area of the front, m^2
Cd = 0.7963; % Aero drag coefficient
rho_air = 1.2; % Air density kg/m^3

FR = 1.18; % final drive gear ratio

% VehiclePara.mass = 15076; % vehicle total mass, kg
% VehiclePara.g = 9.81; % Gravity constant
% VehiclePara.Cr = 0.0085; % Rolling resistance constant
% VehiclePara.R_tire = 0.5; % Radius of the tire, m
% 
% VehiclePara.A_front = 9.5; % Area of the front, m^2
% VehiclePara.Cd = 0.7963; % Aero drag coefficient
% VehiclePara.rho_air = 1.2; % Air density kg/m^3

VehiclePara.FR = 1.18; % final drive gear ratio
%% All the following parameters are scaled
% Engine parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICE engine parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Original parameters
% 1.5L Prius_jpn (Atkinson cycle)engine
% Maximum Power 43kW @4000rpm 
% Peak Torque  75 lb-ft @ 4000 rpm.

% Assmuing the Maximum Power will be 300kW @ 2000 rpm
% Peak Torque 1400 N*m @ 2000 rpm

% eng_description='Prius_jpn 1.5L (43kW) from FA model and ANL test data'; 
e_inertia=0.18;           % (kg*m^2), rotational inertia of the engine (unknown)

% SPEED & TORQUE RANGES over which data is defined
% (rad/s), speed range of the engine

% Original Data
eng_map_spd=[104.7 110 115.2 120.4 125.7 130.9 136.1 141.4 ...
            146.6 151.8 157.1 162.3 167.6 172.8 178 183.3 188.5 193.7 199 ...
            204.2 209.4 214.7 219.9 225.1 230.4 235.6 240.9 246.1 251.3 256.6 ...
            261.8 267 272.3 277.5 282.7 288 293.2 298.5 303.7 308.9 314.2 ...
            319.4 324.6 329.9 335.1 340.3 345.6 350.8 356 361.3 366.5 371.8 ...
            377 382.2 387.5 392.7 397.9 403.2 408.4 413.6 418.9];
eng_max_trq=[77.33 78.2 79.07 79.94 80.81 81.68 82.35 82.85 83.35 83.85 ...
            84.35 84.83 85.2 85.58 85.95 86.32 86.7 87.13 87.6 88.08 88.55 ...
            89.02 89.47 89.79 90.11 90.43 90.76 91.08 91.4 91.73 92.05 92.38 ...
            92.7 93.03 93.35 93.67 93.99 94.32 94.64 94.96 95.29 95.61 95.93 ...
            96.26 96.58 96.9 97.22 97.55 97.87 98.19 98.52 98.84 99.17 99.49 ...
            99.81 100.2 100.5 100.9 101.3 101.7 102];
% fuel range is normalized by 1/2.7501
eng_map_fuel=[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
% torque use map indexed vertically by eng_map_spd and horizontally by eng_map_fuel
% lbft2Nm=1.356; %conversion from lbft to Nm

% Scaled 
eng_map_spd = eng_map_spd * (2000 / 4000);
eng_max_trq = eng_max_trq * (1400 / 1.356 / 75);
e_inertia = e_inertia * 10;  % Doesn't find related document, just use 10 times here. 

% 2D Lookup Table (Speed & Fuel to Torque)
eng_map_trq = zeros(length(eng_map_fuel), length(eng_map_spd));
% First index is fuel, second index is speed
for i = 1:length(eng_map_spd)
    for j = 1:length(eng_map_fuel)
        eng_map_trq(j,i) = (j-1)/(length(eng_map_fuel)-1)*eng_max_trq(i);
    end
end

% Engine Fuel Comsumption
eng_consum_spd=[104.7 110 115.2 120.4 125.7 130.9 136.1 141.4 ...
            146.6 151.8 157.1 162.3 167.6 172.8 178 183.3 188.5 193.7 199 ...
            204.2 209.4 214.7 219.9 225.1 230.4 235.6 240.9 246.1 251.3 256.6 ...
            261.8 267 272.3 277.5 282.7 288 293.2 298.5 303.7 308.9 314.2 ...
            319.4 324.6 329.9 335.1 340.3 345.6 350.8 356 361.3 366.5 371.8 ...
            377 382.2 387.5 392.7 397.9 403.2 408.4 413.6 418.9];
% lbft2Nm=1.356; %conversion from lbft to Nm
eng_consum_trq=[0 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
% (g/s), fuel use map indexed vertically by eng_consum_spd and horizontally by eng_consum_trq
eng_consum_fuel=[0 0.654 0.328 0.238 0.232 0.257 0.29 0.323 0.353 0.381 0.407 0.435 0.465 0.501 0.545 0.599 0.665 0.746 0.842 0.957;
0 0.667 0.342 0.253 0.249 0.275 0.309 0.343 0.375 0.404 0.432 0.46 0.492 0.53 0.575 0.63 0.697 0.779 0.877 0.993;
0 0.679 0.355 0.268 0.265 0.292 0.327 0.363 0.396 0.426 0.455 0.485 0.518 0.557 0.603 0.659 0.728 0.811 0.91 1.03;
0 0.691 0.368 0.282 0.28 0.308 0.345 0.382 0.416 0.447 0.477 0.509 0.543 0.583 0.63 0.688 0.758 0.842 0.942 1.06;
0 0.701 0.38 0.295 0.294 0.324 0.362 0.4 0.435 0.468 0.499 0.531 0.567 0.608 0.657 0.716 0.787 0.872 0.974 1.09;
0 0.711 0.391 0.307 0.308 0.342 0.38 0.418 0.451 0.483 0.515 0.554 0.59 0.632 0.682 0.742 0.815 0.901 1 1.12;
0 0.721 0.402 0.32 0.321 0.359 0.397 0.436 0.474 0.506 0.538 0.58 0.622 0.656 0.707 0.769 0.842 0.93 1.03 1.16;
0 0.731 0.413 0.331 0.334 0.371 0.413 0.453 0.492 0.528 0.559 0.598 0.649 0.68 0.732 0.794 0.869 0.958 1.06 1.19;
0 0.74 0.423 0.343 0.347 0.383 0.425 0.466 0.508 0.548 0.579 0.617 0.668 0.717 0.756 0.82 0.895 0.985 1.09 1.22;
0 0.749 0.433 0.354 0.359 0.395 0.437 0.478 0.52 0.561 0.597 0.636 0.687 0.738 0.78 0.844 0.921 1.01 1.12 1.25;
0 0.758 0.443 0.366 0.372 0.407 0.448 0.49 0.532 0.577 0.611 0.656 0.708 0.76 0.803 0.869 0.947 1.04 1.15 1.27;
0 0.767 0.453 0.377 0.384 0.419 0.46 0.502 0.546 0.594 0.628 0.676 0.728 0.781 0.832 0.893 0.972 1.07 1.18 1.3;
0 0.776 0.464 0.388 0.396 0.43 0.472 0.516 0.563 0.611 0.648 0.697 0.747 0.8 0.852 0.917 0.997 1.09 1.2 1.33;
0 0.785 0.474 0.399 0.409 0.442 0.485 0.533 0.581 0.628 0.669 0.718 0.767 0.819 0.87 0.941 1.02 1.12 1.23 1.36;
0 0.795 0.484 0.411 0.421 0.455 0.503 0.55 0.598 0.645 0.69 0.738 0.787 0.838 0.89 0.97 1.05 1.14 1.26 1.39;
0 0.804 0.495 0.422 0.424 0.472 0.52 0.567 0.615 0.663 0.712 0.763 0.813 0.864 0.918 0.982 1.07 1.17 1.28 1.41;
0 0.814 0.506 0.434 0.446 0.492 0.54 0.588 0.635 0.684 0.738 0.793 0.847 0.901 0.952 1.02 1.1 1.19 1.31 1.44;
0 0.824 0.517 0.446 0.463 0.513 0.56 0.608 0.655 0.705 0.759 0.813 0.868 0.922 0.978 1.05 1.14 1.22 1.34 1.47;
0 0.834 0.528 0.458 0.468 0.529 0.572 0.628 0.676 0.725 0.78 0.834 0.888 0.945 1 1.07 1.16 1.25 1.36 1.5; %19
0 0.845 0.54 0.471 0.486 0.532 0.604 0.628 0.696 0.746 0.8 0.855 0.911 0.969 1.03 1.09 1.18 1.27 1.39 1.52;
0 0.856 0.552 0.484 0.5 0.550 0.605 0.659 0.716 0.767 0.821 0.878 0.936 0.994 1.05 1.11 1.2 1.3 1.42 1.55;
0 0.868 0.564 0.497 0.514 0.564 0.620 0.675 0.729 0.787 0.845 0.903 0.961 1.02 1.08 1.13 1.22 1.32 1.44 1.58;
0 0.88 0.577 0.511 0.529 0.577 0.637 0.689 0.748 0.81 0.869 0.927 0.985 1.04 1.1 1.16 1.25 1.35 1.47 1.61;
0 0.892 0.59 0.525 0.544 0.592 0.652 0.708 0.766 0.844 0.89 0.949 1.01 1.07 1.13 1.18 1.27 1.38 1.5 1.64;
0 0.905 0.603 0.539 0.559 0.609 0.667 0.724 0.786 0.884 0.924 0.969 1.03 1.09 1.15 1.21 1.29 1.4 1.52 1.66;
0 0.918 0.618 0.554 0.575 0.625 0.684 0.746 0.804 0.927 0.96 1 1.05 1.11 1.17 1.23 1.31 1.43 1.55 1.69;
0 0.932 0.632 0.569 0.591 0.642 0.702 0.765 0.825 0.890 0.993 1.04 1.08 1.13 1.19 1.26 1.35 1.45 1.58 1.72;
0 0.946 0.647 0.585 0.607 0.66 0.72 0.785 0.843 0.909 1.03 1.08 1.12 1.15 1.21 1.3 1.39 1.47 1.61 1.75;
0 0.961 0.663 0.602 0.625 0.678 0.739 0.804 0.861 0.929 1.07 1.11 1.16 1.19 1.24 1.33 1.42 1.5 1.63 1.78;
0 0.976 0.679 0.619 0.642 0.696 0.758 0.82 0.882 0.951 1.11 1.14 1.19 1.23 1.27 1.35 1.44 1.53 1.66 1.81;
0 0.992 0.696 0.636 0.66 0.715 0.778 0.841 0.903 0.971 1.044 1.117 1.23 1.27 1.31 1.37 1.46 1.56 1.69 1.83;
0 1.01 0.713 0.654 0.679 0.734 0.798 0.861 0.923 0.990 1.065 1.139 1.26 1.31 1.35 1.4 1.48 1.59 1.72 1.86;
0 1.03 0.731 0.673 0.698 0.754 0.818 0.883 0.945 1.01 1.086 1.162 1.29 1.34 1.39 1.43 1.51 1.62 1.75 1.89;
0 1.04 0.749 0.692 0.718 0.775 0.84 0.905 0.967 1.03 1.107 1.189 1.33 1.38 1.42 1.47 1.53 1.65 1.78 1.92;
0 1.06 0.768 0.711 0.738 0.796 0.861 0.927 0.99 1.05 1.127 1.211 1.36 1.41 1.46 1.5 1.56 1.68 1.81 1.95;
0 1.08 0.788 0.732 0.759 0.817 0.883 0.95 1.01 1.07 1.148 1.233 1.4 1.44 1.49 1.54 1.58 1.72 1.84 1.98;
0 1.1 0.808 0.753 0.781 0.839 0.906 0.973 1.04 1.1 1.169 1.251 1.334 1.431 1.521 1.57 1.62 1.75 1.87 2.01;
0 1.12 0.829 0.774 0.803 0.862 0.93 0.997 1.06 1.12 1.19 1.273 1.358 1.457 1.548 1.61 1.65 1.78 1.9 2.05;
0 1.14 0.851 0.796 0.826 0.885 0.953 1.02 1.09 1.15 1.21 1.296 1.382 1.482 1.582 1.64 1.69 1.81 1.93 2.08;
0 1.16 0.873 0.819 0.849 0.909 0.978 1.05 1.11 1.18 1.24 1.323 1.406 1.508 1.609 1.67 1.72 1.84 1.96 2.11;
0 1.19 0.896 0.842 0.873 0.934 1 1.07 1.14 1.2 1.27 1.346 1.435 1.533 1.636 1.7 1.76 1.87 1.99 2.14;
0 1.21 0.919 0.867 0.898 0.959 1.03 1.1 1.17 1.23 1.29 1.373 1.459 1.559 1.664 1.74 1.79 1.91 2.02 2.17;
0 1.23 0.944 0.891 0.923 0.985 1.05 1.13 1.19 1.26 1.32 1.396 1.489 1.584 1.691 1.77 1.82 1.93 2.07 2.21;
0 1.26 0.969 0.917 0.949 1.01 1.08 1.15 1.22 1.29 1.35 1.424 1.513 1.61 1.718 1.81 1.85 1.96 2.1 2.24;
0 1.28 0.994 0.943 0.976 1.04 1.11 1.18 1.25 1.32 1.38 1.452 1.537 1.636 1.745 1.84 1.89 1.99 2.13 2.27;
0 1.31 1.02 0.97 1 1.07 1.14 1.21 1.28 1.34 1.41 1.475 1.567 1.661 1.773 1.87 1.92 2.02 2.17 2.31;
0 1.34 1.05 0.997 1.03 1.09 1.17 1.24 1.31 1.37 1.44 1.503 1.591 1.687 1.8 1.91 1.96 2.05 2.2 2.34;
0 1.36 1.08 1.03 1.06 1.12 1.2 1.27 1.34 1.41 1.47 1.538 1.622 1.712 1.835 1.904 1.988 2.09 2.23 2.38;
0 1.39 1.1 1.05 1.09 1.15 1.23 1.3 1.37 1.44 1.5 1.567 1.645 1.745 1.862 1.933 2.026 2.13 2.26 2.41;
0 1.42 1.13 1.08 1.12 1.18 1.26 1.33 1.4 1.47 1.54 1.6 1.67 1.75 1.882 1.963 2.056 2.16 2.3 2.45;
0 1.45 1.16 1.11 1.15 1.21 1.29 1.36 1.43 1.5 1.57 1.64 1.71 1.78 1.91 1.994 2.086 2.2 2.34 2.48;
0 1.48 1.19 1.15 1.18 1.25 1.32 1.39 1.47 1.53 1.6 1.67 1.74 1.82 1.936 2.024 2.124 2.23 2.37 2.52;
0 1.51 1.23 1.18 1.21 1.28 1.35 1.43 1.5 1.57 1.64 1.7 1.78 1.85 1.964 2.0053 2.154 2.271 2.41 2.56;
0 1.54 1.26 1.21 1.25 1.31 1.39 1.46 1.53 1.6 1.67 1.74 1.81 1.89 1.97 2.07 2.18 2.31 2.45 2.59;
0 1.58 1.29 1.24 1.28 1.35 1.42 1.5 1.57 1.64 1.71 1.77 1.85 1.92 2.01 2.11 2.21 2.39 2.49 2.63;
0 1.61 1.32 1.28 1.31 1.38 1.45 1.53 1.6 1.67 1.74 1.81 1.88 1.96 2.05 2.14 2.25 2.49 2.52 2.67;
0 1.64 1.36 1.31 1.35 1.42 1.49 1.57 1.64 1.71 1.78 1.85 1.92 2 2.09 2.18 2.29 2.41 2.56 2.71;
0 1.68 1.39 1.35 1.38 1.45 1.53 1.6 1.68 1.75 1.81 1.88 1.96 2.04 2.12 2.22 2.33 2.45 2.6 2.75;
0 1.71 1.43 1.38 1.42 1.49 1.56 1.64 1.71 1.78 1.85 1.92 2 2.07 2.16 2.26 2.37 2.49 2.64 2.79;
0 1.75 1.47 1.42 1.46 1.53 1.6 1.68 1.75 1.82 1.89 1.96 2.03 2.11 2.2 2.3 2.41 2.53 2.67 2.83;
0 1.79 1.5 1.46 1.5 1.56 1.64 1.72 1.79 1.86 1.93 2 2.07 2.15 2.24 2.34 2.45 2.57 2.71 2.87];

% Scale
% Assuming original MPG is around 30, and heavy duty vehicle MPG will be 5
% which means 6 times
eng_consum_spd = eng_consum_spd / 2;
eng_consum_trq = eng_consum_trq * (1400 / 1.356 / 75);
eng_consum_fuel = eng_consum_fuel * 6;

% Generator parameters
g_description='PRIUS_JPN 15-kW permanent magnet motor/controller';
g_inertia=0.0226; % (kg*m^2), rotor's rotational inertia																		
g_mass=32.7; % (kg), mass of machine and enclosure
% Generator power keep the same
% (N*m), torque vector corresponding to columns of efficiency & loss maps
g_map_trq=[-55 -45 -35 -25 -15 -5 0 5 15 25 35 45 55];
% (rad/s), speed vector corresponding to rows of efficiency & loss maps
g_map_spd=[-6000 -5500 -4000 -3500 -3000 -2500 -2000 -1500 -1000 -500 0 500 1000 1500 2000 2500 3000 3500 4000 5500 6000]*(2*pi)/60; 
% data reported was from 500 rpm to 4000 rpm, values for 0 and 5500 rpm are identical
% to nearest neighbors. Map was mirrored for negative values
% LOSSES AND EFFICIENCIES
%multiply everything by 0.95 for power electronics efficiency
g_eff_map=0.95*[...
0.88	0.89	0.90	0.91	0.90	0.79	0.79	0.79	0.90	0.91	0.90	0.89	0.88
0.88	0.89	0.90	0.91	0.90	0.79	0.79	0.79	0.90	0.91	0.90	0.89	0.88
0.88	0.89	0.90	0.91	0.90	0.79	0.79	0.79	0.90	0.91	0.90	0.89	0.88
0.87	0.88	0.90	0.90	0.90	0.80	0.80	0.80	0.90	0.90	0.90	0.88	0.87
0.85	0.87	0.89	0.90	0.90	0.81	0.81	0.81	0.90	0.90	0.89	0.87	0.85
0.83	0.85	0.87	0.89	0.89	0.82	0.82	0.82	0.89	0.89	0.87	0.85	0.83
0.80	0.83	0.85	0.87	0.89	0.82	0.82	0.82	0.89	0.87	0.85	0.83	0.80
0.76	0.79	0.82	0.85	0.87	0.82	0.82	0.82	0.87	0.85	0.82	0.79	0.76
0.68	0.72	0.76	0.80	0.84	0.81	0.80	0.81	0.84	0.80	0.76	0.72	0.68
0.52	0.57	0.63	0.69	0.77	0.80	0.80	0.80	0.77	0.69	0.63	0.57	0.52
0.52	0.57	0.63	0.69	0.77	0.80	0.80	0.80	0.77	0.69	0.63	0.57	0.52
0.52	0.57	0.63	0.69	0.77	0.80	0.80	0.80	0.77	0.69	0.63	0.57	0.52
0.68	0.72	0.76	0.80	0.84	0.81	0.80	0.81	0.84	0.80	0.76	0.72	0.68
0.76	0.79	0.82	0.85	0.87	0.82	0.82	0.82	0.87	0.85	0.82	0.79	0.76
0.80	0.83	0.85	0.87	0.89	0.82	0.82	0.82	0.89	0.87	0.85	0.83	0.80
0.83	0.85	0.87	0.89	0.89	0.82	0.82	0.82	0.89	0.89	0.87	0.85	0.83
0.85	0.87	0.89	0.90	0.90	0.81	0.81	0.81	0.90	0.90	0.89	0.87	0.85
0.87	0.88	0.90	0.90	0.90	0.80	0.80	0.80	0.90	0.90	0.90	0.88	0.87
0.88	0.89	0.90	0.91	0.90	0.79	0.79	0.79	0.90	0.91	0.90	0.89	0.88
0.88	0.89	0.90	0.91	0.90	0.79	0.79	0.79	0.90	0.91	0.90	0.89	0.88
0.88	0.89	0.90	0.91	0.90	0.79	0.79	0.79	0.90	0.91	0.90	0.89	0.88];

% LIMITS
g_max_crrnt=300;	% maximum current draw for motor/controller set, A
g_min_volts=60;	% minimum voltage for motor/controller set, V
% maximum continuous torque corresponding to speeds in g_map_spd
%a guess!!
g_max_spd=[-200000 -10000 -8000 -6500 -5500 -4000 -3500 -3000 -2500 -2000 -1500 -1000 -500 0 500 1000 1500 2000 2500 3000 3500 4000 5500 6500 8000 10000 200000]*(2*pi)/60; 
g_max_trq=1.2*[0.01 14.3 18 22 26 36 41 48 55 55 55 55 55 55 55 55 55 55 55 48 41 36 26 22 18 14.3 0.01]; % (N*m)

% Electrical Motor parameters
m_description='PRIUS_JPN 30-kW permanent magnet motor/controller';
m_inertia=0.0226; % (kg*m^2), rotor's rotational inertia
% Assuming 10 times inertia
m_inertia = m_inertia * 10;

m_mass=56.75; % (kg), mass of motor and enclosure

% (rad/s), speed range of the motor
m_map_spd=[0 500 1000 1500 2000 2500 3000 3500 4000 4500 6000]*(2*pi)/60;
% (N*m), torque range of the motor
m_map_trq=[-305 -275 -245 -215 -185 -155 -125 -95 -65 -35 -5 0 5 35	65 95 125 155 185 215 245 275 305];
% (--), efficiency map indexed vertically by m_map_spd and horizontally by m_map_trq
% multiplied by 0.95 because data was for motor only, .95 accounts for inverter/controller efficiencies
m_eff_map=0.95*[...
.905    .905    .905    .905    .905    .905    .905    .905    .905    .905    .905    .905	.905    .905    .905    .905    .905    .905    .905    .905    .905    .905    .905      
0.56	0.59	0.62	0.65	0.68	0.72	0.76	0.80	0.85	0.90	0.87	.905	0.87	0.90	0.85	0.80	0.76	0.72	0.68	0.65	0.62	0.59	0.56
0.72	0.74	0.76	0.78	0.81	0.83	0.86	0.89	0.91	0.94	0.85	.905	0.85	0.94	0.91	0.89	0.86	0.83	0.81	0.78	0.76	0.74	0.72
0.72	0.74	0.76	0.78	0.86	0.88	0.90	0.92	0.93	0.94	0.83	.905	0.83	0.94	0.93	0.92	0.90	0.88	0.86	0.78	0.76	0.74	0.72
0.72	0.74	0.76	0.78	0.86	0.88	0.92	0.93	0.95	0.95	0.82	.905	0.82	0.95	0.95	0.93	0.92	0.88	0.86	0.78	0.76	0.74	0.72
0.72	0.74	0.76	0.78	0.86	0.88	0.92	0.94	0.95	0.95	0.81	.905	0.81	0.95	0.95	0.94	0.92	0.88	0.86	0.78	0.76	0.74	0.72
0.72	0.74	0.76	0.78	0.86	0.88	0.92	0.95	0.96	0.95	0.81	.905	0.81	0.95	0.96	0.95	0.92	0.88	0.86	0.78	0.76	0.74	0.72
0.72	0.74	0.76	0.78	0.86	0.88	0.92	0.95	0.96	0.95	0.80	.905	0.80	0.95	0.96	0.95	0.92	0.88	0.86	0.78	0.76	0.74	0.72
0.72	0.74	0.76	0.78	0.86	0.88	0.92	0.95	0.95	0.95	0.80	.905	0.80	0.95	0.95	0.95	0.92	0.88	0.86	0.78	0.76	0.74	0.72
0.72	0.74	0.76	0.78	0.86	0.88	0.92	0.95	0.95	0.95	0.79	.905	0.79	0.95	0.95	0.95	0.92	0.88	0.86	0.78	0.76	0.74	0.72		
0.72	0.74	0.76	0.78	0.86	0.88	0.92	0.95	0.95	0.95	0.79	.905	0.79	0.95	0.95	0.95	0.92	0.88	0.86	0.78	0.76	0.74	0.72];		

% Scale
% Assuming Electrical Motor for Heavy Duty Vehicle is 200kW
% Assuming the speed won't change, just increase the torque
m_map_trq = m_map_trq * (200 / 30);

% LIMITS
%m_max_crrnt=90;	% maximum current draw for motor/controller set, A
m_max_crrnt=120;
% UQM's max current is 'adjustable,' above is an estimate
m_min_volts=60;	% minimum voltage for motor/controller set, V
% maximum continuous torque corresponding to speeds in mc_map_spd
m_max_trq_data=[305.0 305.0 305.0 305.0 305.0 244.0 203.3 174.3 152.5 135.6 122.0 110.9 101.7 93.8 87.1 81.3 76.3 71.8 67.8 47.7];
% Scaled
m_max_trq_data = m_max_trq_data * (200 / 30);

m_spd_data=[0 235 470 705 940 1175 1410 1645 1880 2115 2350 2585 2820 3055 3290 3525 3760 3995 4230 6000]*(2*pi)/60;
m_max_trq=interp1(m_spd_data,m_max_trq_data,m_map_spd,'linear');
m_max_gen_trq=-m_max_trq; % estimate
clear m_max_trq_data m_spd_data

%% Gear Set Parameters
% global Is Ig Ic Ie Im Ir Ns Nr N
Ns = 30;  % number of teeth in sun gear
Nr = 78;  % number of teeth in ring gear
N = 4;    % number of pinion gears

% Assuming inertia is 0
Ir = 0;   % ring gear inertia
Is = 0;   % sun gear inertia
Ic = 0;   % carrier gear inertia

Im = m_inertia; % motor inertia
Ig = g_inertia; % generator inertia
Ie = e_inertia; % engine inertia

VehiclePara.Ns = 30;  % number of teeth in sun gear
VehiclePara.Nr = 78;  % number of teeth in ring gear
VehiclePara.N = 4;    % number of pinion gears

% Assuming inertia is 0
VehiclePara.Ir = 0;   % ring gear inertia
VehiclePara.Is = 0;   % sun gear inertia
VehiclePara.Ic = 0;   % carrier gear inertia

VehiclePara.Im = m_inertia; % motor inertia
VehiclePara.Ig = g_inertia; % generator inertia
VehiclePara.Ie = e_inertia; % engine inertia

%% File content
ess.list.init ={'soc_min','soc_max','soc_init','num_module','num_module_parallel','packaging_factor'};
ess.init.num_module_parallel = 1;
ess.init.soc_init = 0.7;
ess.init.element_per_module = 8;
ess.init.num_module = 16; % value for number of modules
ess.init.num_cell_series = ess.init.num_module*ess.init.element_per_module;
ess.init.volt_nom = 25.6/ess.init.element_per_module;
ess.init.volt_min = 20/ess.init.element_per_module ; % 1 volt time the number of cells
ess.init.volt_max = 28/ess.init.element_per_module; %1.5 volt times the number of cells
ess.init.mass_module = 6.5; %(kg), mass of a single ~12 V module
ess.init.mass_cell = ess.init.mass_module/ess.init.element_per_module;
ess.init.soc_min = 0.2;
ess.init.soc_max = 1.0;
ess.init.packaging_factor = 1.25;
%ess.init.soc_min = overwrite_parameters('simulation.drivetrain.ess','soc_min',ess.init.soc_min);
% need to update to make sure we have 0 power at SOC_min
%Removed Overwrite ess.init.num_cell_series
% LOSS AND EFFICIENCY parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess.init.soc_index = [0:.1:1]; % SOC RANGE over which data is defined
ess.init.temp_index = [0 22 40]; % Temperature range over which data is defined (C)
ess.init.cap_max_map = [40 40 40]; % (A*h), max. capacity at C/5 rate, indexed by ess.init.temp_index
ess.init.eff_coulomb = [1 1 1]; % average coulombic (a.k.a. amp- hour) efficiency below, indexed by ess.init.temp_index
% cell's resistance to being discharged, indexed by ess.init.soc_index and ess.init.temp_index
ess.init.rint_dis_map=0.5*[
0.05 0.016 0.016 0.016 0.015 0.015 0.015 0.015 0.015 0.015 0.010
0.05 0.016 0.016 0.016 0.015 0.015 0.015 0.015 0.015 0.015 0.010
0.05 0.016 0.016 0.016 0.015 0.015 0.015 0.015 0.015 0.015 0.010
]/ess.init.element_per_module; % (ohm)
% cell's resistance to being charged, indexed by ess.init.soc_index and
ess.init.temp_index
ess.init.rint_chg_map=fliplr(ess.init.rint_dis_map);% (ohm), no other data available
% cell's open-circuit (a.k.a. no-load) voltage, indexed by ess.init.soc_index and ess.init.temp_index
ess.init.voc_map=[
24 25.24 25.8 26.06 26.14 26.24 26.34 26.42 26.5 26.6 27
24 25.24 25.8 26.06 26.14 26.24 26.34 26.42 26.5 26.6 27
24 25.24 25.8 26.06 26.14 26.24 26.34 26.42 26.5 26.6 27]/ess.init.element_per_module; % (V)

% Max current and power when charging/discharging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess.init.curr_chg_max = -max(max((ess.init.volt_max-ess.init.voc_map)./ess.init.rint_chg_map));
ess.init.curr_dis_max = max(max((ess.init.voc_map-ess.init.volt_min)./ess.init.rint_dis_map));
%check the ess.calc.pwr_chg & ess.calc.pwr_dis because they're a vector and in the database for the plot we
%need maps
ess.calc.pwr_chg = -max((ess.init.volt_max-ess.init.voc_map).*ess.init.volt_max./ess.init.rint_chg_map);%per cell
ess.calc.pwr_dis = max((ess.init.voc_map-ess.init.volt_min).*ess.init.volt_min./ess.init.rint_dis_map);%per cell
% gain factor to modify ess.calc.pwr_chg and ess.calc.pwr_dis
% discharge is brought to 0 at low SOC and charge is brought to 0 at high
% SOC
% modification by vfreyermuth on 9/8/06
ess.calc.pwr_chg = ess.calc.pwr_chg.*double(ess.init.soc_index <=ess.init.soc_max);
ess.calc.pwr_dis = ess.calc.pwr_dis.* double(ess.init.soc_index >=ess.init.soc_min);
ess.init.pwr_chg = -max(max((ess.init.volt_max-ess.init.voc_map).*ess.init.volt_max./ess.init.rint_chg_map));%per cell
ess.init.pwr_dis = max(max((ess.init.voc_map-ess.init.volt_min).*ess.init.volt_min./ess.init.rint_dis_map));%per cell
% battery thermal model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess.init.therm_on = 1;
% -- 0=no ess thermal calculations, 1=do calc's
ess.init.therm_cp_module = 830;
% J/kgK ave heat capacity of module (estimated for NiMH)
ess.init.temp_reg = 35;
% C thermostat temp of module when cooling fan comes on
ess.tmp.area_mod = 1.6*(ess.init.mass_module/11)^0.7;
% -- if module dimensions are unknown, assume rectang shape and scale vs PB25
ess.tmp.area_module = 0.2*ess.tmp.area_mod;
% m^2 total module surface area exposed to cooling air (typ rectang module)
ess.init.flow_air_mod = 0.01;
% kg/s cooling air mass flow rate across module (20 cfm=0.01 kg/s at 20 C)
ess.tmp.mod_flow_area = 0.005*ess.tmp.area_mod;
% m^2 cross-sec flow area for cooling air per module (assumes 10-mm gap btwn mods)
ess.tmp.case_thk = 2/1000;
% m thickness of module case (typ from Optima)
ess.tmp.therm_case_cond = 0.20;
% W/mK thermal conductivity of module case material (typ polyprop plastic - Optima)
ess.tmp.speed_air = ess.init.flow_air_mod/(1.16*ess.tmp.mod_flow_area); % m/s ave velocity of cooling air

ess.tmp.therm_air_htcoef = 30*(ess.tmp.speed_air/5)^0.8;
% W/m^2K cooling air heat transfer coef.
ess.init.therm_res_on =((1/ess.tmp.therm_air_htcoef)+(ess.tmp.case_thk/ess.tmp.therm_case_cond))/ess.tmp.area_module; % K/W tot thermal res key on
ess.init.therm_res_off =((1/4)+(ess.tmp.case_thk/ess.tmp.therm_case_cond))/ess.tmp.area_module; % K/W tot thermal res key off (cold soak)
ess.init.flow_air_mod = max(ess.init.flow_air_mod,0.001);
ess.init.therm_res_on = min(ess.init.therm_res_on,ess.init.therm_res_off);
if isfield(ess,'tmp')
ess = rmfield(ess,'tmp');
end
% Battery density
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess.init.pwr_dis_nom = max(max((ess.init.volt_nom- ess.init.volt_min).*ess.init.volt_min./ess.init.rint_dis_map));%per cell
ess.init.pwr_density = ess.init.pwr_dis_nom/ess.init.mass_cell;
ess.init.energy_density = mean((ess.init.volt_nom*ess.init.cap_max_map))/ess.init.mass_cell;
%Values should only be used to calculate the number of cells
%ess.init.num_cell_series = overwrite_parameters('simulation.drivetrain.ess','num_cell_series',ess.init.num_cell_series);% need to update to make sure we have 0 power at SOC_min
%ess.init.num_module_parallel = overwrite_parameters('simulation.drivetrain.ess','num_module_parallel',ess.init.num_module_parallel);% need to update to make sure we have 0 power at SOC_min
ess.init.num_cell = ess.init.num_module_parallel.*ess.init.num_cell_series;

%% Battery Parameters
BatteryCapacity = 10080; %wh
% R1 = 0.0027; %ohms
% R2 = 0.0042; %ohms
% C2 = 25000; %farad
% ni = 0.8; %battery Coulombic efficiency
% Cn = 2500; %nominal battery capacity
% 
% A = [1/(R2*C2) 0;
%      0         0];
% B = [1/C2; ni/Cn];
% D = R1;
% 
% ai = [0.0059 0.0049 0.0039 0.0028 0.0036 0.006 0.0082 0.008 0.009 0.0099];
% new_ai = repelem(ai,1,10);
% bi = [3.5052 3.5188 3.5397 3.5728 3.5416 3.4199 3.2864 3.3004 3.2232 3.1364];
% new_bi = repelem(bi,1,10);
% x= 1:100;
% 
% Ki1 = 1;
% Ki2 = [1;1];
% Kp = 2;

len = 90; % total time for simulation
size = len*100; % size of the time space
amplitude = 0.01; % noise amplitude

time = linspace(0, len, size); % 
current = -10-sin(time); % Arbitrary current funtion
measure_current = current + amplitude * rand(1, length(current)); % introduce noise to current
disturbance = amplitude * rand(1, length(current)); % disturbance

% These are just temporary values.
Kp = 1;
Ki1 = 1;
Ki2 = 1;

R1 = 0.0027; % Ohm
R2 = 0.0042; % Ohm
C2 = 25000; % F
ni = 1; % Battery efficiency
Cn = 1000; % A*h

bp = [0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85 0.95];
ai = [0.0059 0.0049 0.0039 0.0028 0.0036 0.006 0.0082 0.008 0.009 0.0099];
bi = [3.5052 3.5188 3.5397 3.5728 3.5416 3.4199 3.2864 3.3004 3.2232 3.1364];

A = [-1/(R2*C2), 0; 0, 0];
B = [1/C2; ni/Cn];
C = [1 ai];
D = R1;

Q = [1 0;0 1];
R = 1;
k = lqr(A,B,Q,R);

capacity = 84; %Ah


%% Fuel Cell Parameter
Vfc = 40; %V
Ivc = 1; %a
ohms_vc = 0.1; %ohms/voltage
Low_heating_value_0f_hydrogen = 1.2*10^8; %j/kg
fc_eff =0.5;
Data = load('Fuel Cell Effiency.txt');
KW = Data(:,1);
Eff = Data(:,2);


%% Regenerative Breaking 
weightfactor = [1 1 1 1 1 0];
SOC = [0 20 40 60 80 100];

weightfactor_ws = [0.01 0.01 1 1 1];
WheelSpeed = [0 30 100 150 201];

%% Sample commands
testTime = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
engine_cmd = [0.1, 0.2, 0.3, 0.4, 0.5, 0.4, 0.4, 0.5, 0.4, 0.3];
generator_cmd = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] * 5;
motor_cmd = 1000 + 20 * [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
k =Nr/Ns;
W2T = [Is+Ig 0 0 -Ns*N;
    0 -Ic+Ie 0 (Ns+Nr)*N;
    0 0 Vehicle_mass*R_tire^2/FR+Im*FR+Ir*FR -FR*Nr*N;
    Ns -(Ns+Nr) Nr 0];

SP = fopen('DrivingCycle2.txt');
cdata=textscan(SP,'%f%f', 'HeaderLines', 2 );
fclose(SP);
Time = cdata{1};
Speed = cdata{2};
ws = Speed.*(0.44704/0.5);
maxws = max(ws);
minws = min(ws);


%% ECMS
%{
ECMS Supervisor Model for Hybrid Vehicle Model
WRITTEN BY: Matt Asper
DATE: 21 April 2023
%}
% clear

%% Constants
%State of charge
SOC_L = 0.1; %min
SOC_H = 0.9; %max
SOC_range = 0:.1:1; %iterations 

%Powers
Pmax = 200e3; %assume Pmax = 30 kW
P_demand = linspace(0,Pmax,10);
P_eng_range = 0:.1:1;
P_motor_range = 0:.1:1;

%Speeds
Vmax = 2000; %rpm
V_range = linspace(0,Vmax,10)*2*pi/60; %rad/s
% V_range = 0:.1:1; %rad/s

%Optimal Powers
%3d lookup of engine powers indexed by: (Pd,V,SOC)
P_eng_opt = zeros(length(P_demand),length(V_range),length(SOC_range));

%3d lookup of motor powers indexed by: (Pd,V,SOC)
P_motor_opt = zeros(length(P_demand),length(V_range),length(SOC_range));

%Optimal Fuel Consumptions
mdot_opt = zeros(length(P_demand),length(V_range),length(SOC_range));

%% Load efficiency maps
%engine fuel use map row-indexed by speed (rad/s) and col-indexed by 
%P_eng/speed
load('eng_consum_fuel.mat');

%motor eff map row-indexed by speed (rad/s) and col-indexed by
%P_motor/speed
load('m_eff_map.mat');


%% Loop to find optimal fuel consumption
for k = 1:length(SOC_range)
    SOCi = SOC_range(k);

    for j = 1:length(V_range)
        Spd = V_range(j); %current speed

        %initialize dummy fuel consumption table
        fuel_consump = zeros(length(P_demand),2);
        for i = 1:length(P_demand)
            Power = P_demand(i); %current power demanded
            P_eng = P_eng_range*Power;
            P_motor = Pmax-P_eng;

            mdot_eng = interp2(eng_consum_spd,eng_consum_trq,eng_consum_fuel',Spd,P_eng/Spd)'; %engine fuel consum
            
            motor_eff = interp2(m_map_spd,m_map_trq,m_eff_map',Spd,P_motor/Spd)'; %motor eff
            x_soc = (SOCi - .5*(SOC_L + SOC_H))/(SOC_H - SOC_L);
            f_soc = 1-(1-.7*x_soc)*x_soc^3;
            SC_eng = .23/1000; %average fuel consumption (kg/W-hr)
            mdot_motor = f_soc*SC_eng*P_motor./motor_eff; %motor fuel consum

            mdot_total = mdot_eng + mdot_motor;

            %find min fuel consum
            [mdot_opt(i,j,k),min_idx] = min(mdot_total);

            %save data
            P_eng_opt(i,j,k) = P_eng(min_idx);
            P_motor_opt(i,j,k) = P_motor(min_idx);            
            
        end

    end

end






