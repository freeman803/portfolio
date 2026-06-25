clear;
%% DATA %%
%ENDURANCE_DATA = readtable('cage_eload_testing_enduranceSIM.xlsx', 'Sheet', 'Bak45D-3');
ENDURANCE_DATA = readtable('EnduranceResults.csv');
%ENDURANCE_DATA = readtable('S1_#4226_20240615_163852-1.5FOS.csv');
time = ENDURANCE_DATA.Var6;
voltage = ENDURANCE_DATA.Var3;
I = -ENDURANCE_DATA.Var4;
%time = ENDURANCE_DATA.time;
%I = -ENDURANCE_DATA.current;
%voltage = ENDURANCE_DATA.voltage;
Ri_table_discharge = [0.0079,0.0066,0.0065,0.0056,0.0054,0.0062,0.0062,0.0063,0.0068,0.0074,0];
Ri_table_charge = [0.0084,0.0062,0.0061,0.0057,0.0061,0.0058,0.0056,0.0032,7.10E-03,0.0081,0];
R1_table_discharge = [0.0045,0.0024,0.0028,0.0024,0.0021,0.0019,0.0019,0.002,0.0032,0.0049,0];
R1_table_charge = [7.94E-06,0.0019,0.0018,0.0015,0.0014,0.0013,0.0013,0.0033,0.0102,0.011,0];
R2_table_discharge = [0.0274,0.0092,0.0126,0.0142,0.0074,0.0098,0.012,0.0167,0.0781,0.1063,0];
R2_table_charge = [0.009,0.0058,0.0066,0.0066,0.0049,0.0046,0.0047,0.005,0.003,0.004,0];
C1_table_discharge = [625.5498,1.0884e+03,1.3760E+03,671.7873,447.4289,1.46E+03,1.59E+03,1.94E+03,1.75E+03,697.3229,0];
C1_table_charge = [629.4704,653.2170,732.6093,516.2969,1.31E+03,707.6551,411.8151,13.8447,1.46E+03,898.8253,0];
C2_table_discharge = [2.05E+03,2.9757e+03,3.2006E+03,2.65E+03,3.27E+03,3.60E+03,3.37E+03,2.97E+03,2.23E+03,1.25E+03,0];
C2_table_charge = [700.7608,2.5740e+03,2.3650e+03,2.09E+03,3.42E+03,2.54E+03,2.29E+03,1.93E+03,1.33E+04,6.06E+03,0];
start_time = 2;
end_time = 9189;
idx = (time >= start_time & time <= end_time);
t = (start_time:0.01:end_time)';
%I = interp1(time(idx), I(idx), t, 'linear', 'extrap');
%[time_unique, ia] = unique(time);      % keep only unique time entries
%voltage_unique = voltage(ia);          % match the voltage values
%voltage_interp = interp1(time_unique, voltage_unique, t, 'linear');
OCV_lookup = [2.42,3.17577,3.36868,3.52009,3.62396,3.74948,3.84225,3.93877,4.05245,4.0853,4.18972]; % data from hppc test
SOC_lookupR = linspace(0,1,11);
figure
plot(voltage(6:9000), 'b-');
hold on
Q = 4.5 * 3600;   %battery charge
SOC_lookupR = linspace(0,1,11);
%SOC_lookup = linspace(0,1,21);
%OCV_lookup = [2.42,2.6,3.17577,3.3,3.31,3.36868,3.37,3.52009,3.6,3.62396,3.7,3.74948, ...
%    3.8,3.84225,3.9,3.93877,4,4.0,4.0,4.15,4.18997]; % data from hppc test
    OCV_lookup = [2.42,3.17577,3.36868,3.52009,3.62396,3.74948,3.84225,3.93877,4.05245,4.0853,4.2]; % data from hppc test
%OCV_lookup = [2.5911,2.8401,3.0691,3.2781,3.4671,3.6361,3.7851,3.885,3.925,4.023,4.098];       % data from andrew
SOC = 1;
%% WEIGHTED SUM %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Vrc1 = 0; Vrc2 = 0;
Vs = zeros(size(t));
SOC_a = zeros(size(t));
SOC_an = zeros(size(t));
SOC_coul = zeros(size(t));
for k = 1:(length(time)-2)
dt = time(k+1)-time(k);
%    if dt<0.12
%        dt=0.2;
%    end
    SOC_index = round(10 - SOC*(10))+1;
    if I(k) > 0
        Ri = interp1(SOC_lookupR, Ri_table_charge, 1-SOC, 'linear', 'extrap');
        R1 = interp1(SOC_lookupR, R1_table_charge, 1-SOC, 'linear', 'extrap');
        R2 = interp1(SOC_lookupR, R2_table_charge, 1-SOC, 'linear', 'extrap');
        C1 = interp1(SOC_lookupR, C1_table_charge, 1-SOC, 'linear', 'extrap');
        C2 = interp1(SOC_lookupR, C2_table_charge, 1-SOC, 'linear', 'extrap');
    end
    if I(k) <= 0
        Ri = interp1(SOC_lookupR, Ri_table_discharge, 1-SOC, 'linear', 'extrap');
        R1 = interp1(SOC_lookupR, R1_table_discharge, 1-SOC, 'linear', 'extrap');
        R2 = interp1(SOC_lookupR, R2_table_discharge, 1-SOC, 'linear', 'extrap');
        C1 = interp1(SOC_lookupR, C1_table_discharge, 1-SOC, 'linear', 'extrap');
        C2 = interp1(SOC_lookupR, C2_table_discharge, 1-SOC, 'linear', 'extrap');
    end
    SOC = SOC + (I(k)*1* dt ) / (Q*1);
    %SOC = max(0, min(1, SOC));
    VOC = interp1(SOC_lookupR, OCV_lookup, SOC, 'linear', 'extrap');
    dVrc1 = (-Vrc1/(R1*C1) + I(k)*1.0/C1) * dt;
    dVrc2 = (-Vrc2/(R2*C2) + I(k)*1.0/C2) * dt;
    Vrc1 = Vrc1 + dVrc1;
    Vrc2 = Vrc2 + dVrc2;
    Vs(k) = VOC + I(k)*1.0*Ri + Vrc1 + Vrc2;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    VOC_a = -(I(k)*1.0*Ri + Vrc1 + Vrc2) + voltage(k);
    %SOC_a(k) = interp1(OCV_lookup, SOC_lookupR, VOC_a, 'linear', 'extrap');
if abs(I(k)) < 4
    SOC_a = interp1(OCV_lookup, SOC_lookupR, VOC_a, 'linear', 'extrap');
    %fprintf('soc:\n', SOC_a);
    SOC = 0.997*SOC + 0.003*SOC_a;
    SOC_an(k)=SOC;
end
SOC = min(1, max(0, SOC));
    if mod(k,10) == 0
        fprintf('Vs=%.3f s, SOC=%.3f, VOC_a=%.3f,  voltage=%.3f, v_up=%.3f\n', Vs(k), SOC, VOC_a, voltage(k), -(I(k)*1.0*Ri + Vrc1 + Vrc2));
    end
end
SOC_c = 1;
for k = 1:(length(time)-2)
    SOC_c = SOC_c + (I(k)*1* dt ) / (Q*1);
    SOC_coul(k) = SOC_c;
end
Delta_t = 0.55;
Vs = interp1(t, Vs, t-Delta_t, 'linear', 'extrap');%
V_meas_interp = interp1(time(idx), voltage(idx), t, 'linear', 'extrap');
% least squares error metrics
SSE  = sum((Vs - V_meas_interp).^2);              % sum of squared errors
MSE  = mean((Vs - V_meas_interp).^2);             % mean squared error
RMSE = sqrt(mean((Vs - V_meas_interp).^2));       % root mean square error
fprintf('SSE  = %.6f\n', SSE);
fprintf('MSE  = %.6f\n', MSE);
fprintf('RMSE = %.6f\n', RMSE);
%plot(t, voltage_interp, 'b', 'LineWidth', 1); hold on;
plot(Vs(60:9189), 'r', 'LineWidth', 0.9);
xlabel('Time (s)'), ylabel('Voltage (V)')
title('weighted sum')
figure;
plot(SOC_an(60:9189), 'o', 'LineWidth', 0.9);hold on;
plot(SOC_coul(60:9189), 'r','LineWidth', 0.9);
grid on
xlabel('Time (s)'), ylabel('SOC (V)')
%legend('SOC', 'Simulated ECM')
title('SOC over time')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}
%% KALMAN FILTER
clear;
%ENDURANCE_DATA = readtable('cage_eload_testing_enduranceSIM.xlsx', 'Sheet', 'Bak45D-3');
ENDURANCE_DATA = readtable('EnduranceResults.csv');
%ENDURANCE_DATA = readtable('S1_#4226_20240615_163852-1.5FOS.csv');
%time = ENDURANCE_DATA.time;
%voltage = ENDURANCE_DATA.voltage;
%I = ENDURANCE_DATA.current;
time = ENDURANCE_DATA.Var6;
voltage = ENDURANCE_DATA.Var3;
I = ENDURANCE_DATA.Var4;
%time = ENDURANCE_DATA.Time;
%I = -ENDURANCE_DATA.CurrentPerCell;
Ri_table_discharge = [0.0079,0.0066,0.0065,0.0056,0.0054,0.0062,0.0062,0.0063,0.0068,0.0074,0];
Ri_table_charge = [0.0084,0.0062,0.0061,0.0057,0.0061,0.0058,0.0056,0.0032,7.10E-03,0.0081,0];
R1_table_discharge = [0.0045,0.0024,0.0028,0.0024,0.0021,0.0019,0.0019,0.002,0.0032,0.0049,0];
R1_table_charge = [7.94E-06,0.0019,0.0018,0.0015,0.0014,0.0013,0.0013,0.0033,0.0102,0.011,0];
R2_table_discharge = [0.0274,0.0092,0.0126,0.0142,0.0074,0.0098,0.012,0.0167,0.0781,0.1063,0];
R2_table_charge = [0.009,0.0058,0.0066,0.0066,0.0049,0.0046,0.0047,0.005,0.003,0.004,0];
C1_table_discharge = [625.5498,1.0884e+03,1.3760E+03,671.7873,447.4289,1.46E+03,1.59E+03,1.94E+03,1.75E+03,697.3229,0];
C1_table_charge = [629.4704,653.2170,732.6093,516.2969,1.31E+03,707.6551,411.8151,13.8447,1.46E+03,898.8253,0];
C2_table_discharge = [2.05E+03,2.9757e+03,3.2006E+03,2.65E+03,3.27E+03,3.60E+03,3.37E+03,2.97E+03,2.23E+03,1.25E+03,0];
C2_table_charge = [700.7608,2.5740e+03,2.3650e+03,2.09E+03,3.42E+03,2.54E+03,2.29E+03,1.93E+03,1.33E+04,6.06E+03,0];
%start_time = 60000;
%end_time = 75000;
start_time = 1;
end_time = 1086;
start_point=2;
end_point=9012;
idx = (time >= start_time & time <= end_time);
%{
t = (start_time:0.01:end_time)';
I = interp1(time(idx), I(idx), t, 'linear', 'extrap');
[time_unique, ia] = unique(time);      % keep only unique time entries
voltage_unique = voltage(ia);          % match the voltage values
voltage_interp = interp1(time_unique, voltage_unique, t, 'linear');
%}
OCV_lookup = [2.42,3.17577,3.36868,3.52009,3.62396,3.74948,3.84225,3.93877,4.05245,4.0853,4.18005]; % data from hppc test
SOC_lookupR = linspace(0,1,11);
OCV_lookup = [2.42,3.178,3.37,3.52,3.62,3.75,3.84,3.94,4.05,4.09,4.20];
%figure
%plot(time(idx), voltage(idx), 'b-');
%hold on
%% KALMAN FILTER %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize
Q = 4.5 * 3600;   %battery charge
Q_used=0;
%dt = (t(2)-t(1));
SOC_est = 0.99;               % start at 100%
SOC_coul=1;
Q_noise = [7e-8 0 0; 0 6e-5 0; 0 0 6e-5];     %process noise
R_noise = 0.05;                                    %Measurement Noise
L = 1;
X = [1; 0; 0];  %state
P = [1e-4 0 0 ; 0 1e-4 0; 0 0 1e-4];    %covariance
dOCV = gradient(OCV_lookup, SOC_lookupR);
m=0;
SOC_k=1;
%for k = 1:length(t)
for k = start_point:end_point
    dt = time(k)-time(k-1);
    %if dt<0.12
    %    dt=0.2;
    %end
    Q_used=Q_used+((I(k-1)*dt));

    SOC = X(1);
    if I(k) < 0
        Ri = interp1(SOC_lookupR, Ri_table_charge, 1-SOC, 'linear', 'extrap');
        R1 = interp1(SOC_lookupR, R1_table_charge, 1-SOC, 'linear', 'extrap');
        R2 = interp1(SOC_lookupR, R2_table_charge, 1-SOC, 'linear', 'extrap');
        C1 = interp1(SOC_lookupR, C1_table_charge, 1-SOC, 'linear', 'extrap');
        C2 = interp1(SOC_lookupR, C2_table_charge, 1-SOC, 'linear', 'extrap');
    end
    if I(k) >= 0
        Ri = interp1(SOC_lookupR, Ri_table_discharge, 1-SOC, 'linear', 'extrap');
        R1 = interp1(SOC_lookupR, R1_table_discharge, 1-SOC, 'linear', 'extrap');
        R2 = interp1(SOC_lookupR, R2_table_discharge, 1-SOC, 'linear', 'extrap');
        C1 = interp1(SOC_lookupR, C1_table_discharge, 1-SOC, 'linear', 'extrap');
        C2 = interp1(SOC_lookupR, C2_table_discharge, 1-SOC, 'linear', 'extrap');
    end
    tao1 = R1*C1; tao2 = R2*C2;
    V_R1 = ((exp(-dt/tao1))*X(2) + R1*(1-exp(-dt/tao1))*I(k));
    V_R2 = ((exp(-dt/tao2))*X(3) + R2*(1-exp(-dt/tao2))*I(k));
    VOCV = interp1(SOC_lookupR, OCV_lookup, X(1), 'linear', 'extrap');
    Ut = VOCV - V_R1 - V_R2 - I(k)*Ri;
    A = [1 0 0; 0 exp(-dt/tao1) 0; 0 0 exp(-dt/tao2)];
    B = [-dt/Q; R1*(1-exp(-dt/tao1)); R2*(1-exp(-dt/tao2))];
    X = A*X + B*I(k);                   %state predication
    P = A*P*A' + Q_noise;               %covariance prediction
    SOC=X(1);
    dOCV_value = interp1(SOC_lookupR, dOCV, SOC, 'linear', 'extrap');
    H = [dOCV_value -1 -1];
    %error = voltage_interp(k) - Ut;     %error between prediction and actual
    error = voltage(k) - Ut;     %error between prediction and actual
    K1 = P*H'*(H*P*H' + R_noise)^-1;    %kalman gain calc
    X = X+K1*error;          %state matrix update
    P = (eye(3,3) - K1*H)*P; %covariance matrix update

    if mod(k,100)==0
        fprintf('t=%.1f s, SOC=%.3f, I=%.3f, Vs_pred=%.3f\n', time(k), X(1), I(k), Ut);
    end
    %if Ut<2 || Ut>4.2
    %    Vs(k)=Vs(k-1);
    %else
        Vs(k) = Ut;
    %end
    SOC_k(k) = X(1);
end
plot(SOC_k(60:9012), 'm','LineWidth', 1.5);
legend('weighted sum', 'coulomb count', 'kalman')
figure;
plot(time(start_point:end_point), voltage(start_point:end_point), 'b', 'LineWidth', 1); hold on;
plot(time(start_point:end_point), Vs(start_point:end_point), 'r', 'LineWidth', 0.9);
title('kalman filter')
grid on
SOC_final=(Q-Q_used)/Q;
SOC_coul = 1;
for k = start_point:end_point
    dt = time(k) - time(k-1);
    %if dt<0.1
    %    dt=0.2;
    %end
    SOC_coul = SOC_coul - (I(k-1)*dt)/Q;
    SOC_coul = max(0, min(1, SOC_coul));
end
%}
