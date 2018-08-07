% function [] = example_1()

% Init
addpath(genpath('builder'))
addpath(genpath('library'))
addpath(genpath('simulation'))

% Create or load model
sys = simulation.load('matsim_model');
sys.setSolver('Ts',0.01,'DiscreteOnly',true)
sys.clear()
sys.show()

%% Create
v1 = LowPass(FromWorkspace('V_FL'),3);
v2 = LowPass(FromWorkspace('V_FR'),3);
v3 = LowPass(FromWorkspace('V_RL'),3);
v4 = LowPass(FromWorkspace('V_RR'),3);
sys.log(v1,'vfl_filt')
sys.log(v2,'vfr_filt')
sys.log(v3,'vrl_filt')
sys.log(v4,'vrr_filt')

s = Subsystem({v1,v2,v3,v4},'name','slip');
sys.open(s)

s.in(1,'name','FL');
s.in(2,'name','FR');
s.in(3,'name','RL');
s.in(4,'name','RR');

vfl = Max(1,s.in(1));
vfr = Max(1,s.in(2));
vrl = Max(1,s.in(3));
vrr = Max(1,s.in(4));
AvgF = (vfl+vfr).*0.5;
AvgR = (vrl+vrr).*0.5;
Wf = AvgF./Constant('Nominal_Radius_F');
Wr = AvgR./Constant('Nominal_Radius_R');
tauR = 3.15;
tauF = 3.1;
slipCL = 1 - Wf.*tauF./(Wr.*tauR);
s.out(1,slipCL,'name','slip_meas');

sys.open();
sys.log(s,'slip_meas')
sc = Scope(s,'name','slip_meas');
% sc.open()

%% Layout & connect
simlayout(sys.handle)
return

%% Run
% Define variables
dt = read_dspace('D:\WORK\MATLAB\AWD\prove sperimentali\Pozzato\alta_aderenza\07052018_Magna\ac_piazzaledinamico_R_fullgas_60M.IDF.mat');
V_FL = [dt.time, dt.LHFWheelSpeed];
V_FR = [dt.time, dt.RHFWheelSpeed];
V_RL = [dt.time, dt.LHRWheelSpeed];
V_RR = [dt.time, dt.RHRWheelSpeed];
Ts = 0.01;
Nominal_Radius_F = 0.32;
Nominal_Radius_R = 0.32;

% Run simulation
simOut = sys.run('tstop',dt.time(end)).Logs;

% Plot data
colors = get(0,'defaultaxescolororder');
f = figure;
x1 = subplot(2,1,1);
hold all
grid on
plot(simOut.slip_meas.Time,squeeze(simOut.slip_meas.Data))
legend({'slip_meas'},'Interpreter','none')
x2 = subplot(2,1,2);
hold all
grid on
plot(simOut.vfl_filt,'color',colors(1,:))
plot(simOut.vfr_filt,'--','color',colors(1,:))
plot(simOut.vrl_filt,'color',colors(2,:))
plot(simOut.vrr_filt,'--','color',colors(2,:))
legend('V_f_l','V_f_r','V_r_l','V_r_r')
linkaxes([x1,x2],'x')
waitfor(f)

% sys.save()
sys.close()

