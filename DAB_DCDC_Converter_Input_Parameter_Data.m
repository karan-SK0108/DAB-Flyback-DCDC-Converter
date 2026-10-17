clear;
close all;
clc;

Vin = 800; %input voltage
Vout = 800; %output voltage
Pout = 30e3; %output power
fs = 100e3; %switch frequency
N = Vout/Vin;  %Vout/Vin;
n = 1/N;
L_act = 0;

auto_compute_L = (L_act==0);
FOS = 0.8; % 80%
plot_P_Vs_Phi = true;
phi_selection = 'lower'; 

Ts=1/fs; %switch perios sec
omega_s=2*pi*fs; %Angular switching frequency rad/sec

L_req = (Vin*Vout)/(8*n*fs*Pout);
if auto_compute_L
    L_act = L_req*FOS;
end

Pout_max = (Vin*Vout)/(8*n*fs*L_act);
L_max_allowed = (Vin*Vout)/(8*n*fs*Pout);

%solve phi

K=(2 * (pi^2) * fs * L_act * Pout * n) / (Vin*Vout);
disc = (pi^2) - (4 * K);
if disc<0
        phi_sol_rad = NaN;
        phi_sol_deg = NaN; 
else
    sqrt_disc=sqrt(disc);
    phi_a = (pi + sqrt_disc)/2;
    phi_b = (pi - sqrt_disc)/2;
    if strcmpi(phi_selection,'lower')
        phi_sol_rad = phi_b;
    else
        phi_sol_rad = phi_a;
    end
    phi_sol_deg = phi_sol_rad * (180 / pi);
    P_cal = (Vin*Vout)/(2 * n * pi^2 * fs * L_act) * (phi_sol_rad) * (pi-phi_sol_rad);
end

R_load = Vout^2 / Pout;
I_in_avg = Pout / Vin;
I_out_DC = Pout / Vout;
I_Base = Vin / (omega_s*L_act);

dt = Ts/100;

if plot_P_Vs_Phi && disc >=0
    phi_vec = linspace (1e-4,pi-1e-4,2000);
    P_vec = (Vin*Vout) / (2*n*pi^2*fs*L_act) .*(phi_vec.*(pi-phi_vec));
    figure('Name','DAB: Power Vs Phase-Shift','NumberTitle','off');
    plot(phi_vec*180/pi , P_vec/1e3,'LineWidth',1.5);
    hold on;
    grid on;
    xlabel('Phase Shift  \Phi (deg)');
    ylabel('Transferred Power P (kW)');
    [Pout_max_idx,idx] = max(P_vec);
    plot((pi/2)*180/pi , P_vec(idx)/1e3,'ro','MarkerFaceColor','r');
    if ~isnan(phi_sol_rad)
        plot(phi_sol_rad*180/pi,P_cal/1e3,'ks','MarkerFaceColor','k');
    end
    ylim([0,max(P_vec)/1e3*1.2]);
    hold off
end

ripple_percent=3/100;
votlage_ripple= ripple_percent*Vout;
C = I_out_DC / (votlage_ripple*fs);

%Ts=360 | Ts=180 | selected_phi = time?

selected_phi_time = (Ts/360)*(phi_sol_deg);
ratio_constant = selected_phi_time/Ts;

%phi = (90*180)/pi;
%D = 1/2;
