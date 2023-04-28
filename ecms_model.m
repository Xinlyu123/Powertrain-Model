%{
ECMS Supervisor Model for Hybrid Vehicle Model


WRITTEN BY: Matt Asper
DATE: 21 April 2023
%}
% clear

%% Constants
%Gear ratio
GR = 4.56;

%State of charge
SOC_L = 0.2; %min
SOC_H = 1.0; %max
SOC_range = 0:.1:1; %iterations 

%Powers
Pmax = 200e3; %assume Pmax = 30 kW
P_demand = linspace(200,Pmax,10);
P_eng_range = 0:.1:1;
P_motor_range = 0:.1:1;

%Speeds
Vmax = 2000; %rpm
V_range = linspace(200,Vmax,10)*2*pi/60; %rad/s
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
            P_motor = Power-P_eng;

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

%% Plotting
close all;
f1 = figure;
subplot(2,2,1)
contourf(P_demand,V_range,P_eng_opt(:,:,2)')
title('Engine Power (SOC 0.1)')
formatfig

subplot(2,2,2)
contourf(P_demand,V_range,P_motor_opt(:,:,2)')
title('Motor Power (SOC 0.1)')
formatfig

subplot(2,2,3)
contourf(P_demand,V_range,P_eng_opt(:,:,end)')
title('Engine Power (SOC 1)')
formatfig

subplot(2,2,4)
contourf(P_demand,V_range,P_motor_opt(:,:,end)')
title('Motor Power (SOC 1)')
formatfig

h = axes(f1,'visible','off');
f1.Position = [160,64,840,733];
h.Title.Visible = 'off';
h.XLabel.Visible = 'on';
h.YLabel.Visible = 'on';
ylabel(h,'Shaft Speed (rad/s)','FontWeight','bold');
xlabel(h,'Power Demand (W)','FontWeight','bold');
title(h,'title');
c = colorbar(h,'Position',[0.93 0.168 0.022 0.7]);  % attach colorbar to h
colormap
caxis(h,[0,Pmax]);             % set colorbar limits