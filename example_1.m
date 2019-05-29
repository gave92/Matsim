%% Init
close all

import matsim.library.*

% Create or load model
sys = simulation.load('matsim_model');
sys.setSolver('Ts',0.01,'DiscreteOnly',true)
sys.clear()
sys.show()

%% Create
Vx = FromWorkspace('V_x');                    % Add FromWorkspace and Constant blocks
Wr = FromWorkspace('W_r');
Rr = Constant(0.32);

slip = 1 - Vx./(Wr.*Rr);                      % Evaluate complex mathematical expression
sys.log(slip,'name','slip')                   % Log the output of the "slip" block

s = Scope(slip);                              % Create and open scope block
% s.open()

%% Layout & connect
sys.layout()                                  % Connect and layout model

%% Simulate the system
V_x = [0:0.1:10;linspace(5,20,101)]';         % Define input variables
W_r = [0:0.1:10;linspace(5,23,101)/0.32]';
simOut = sys.run('StopTime',10).Logs;         % Simulate the system

figure
hold on
grid on
plot(simOut.slip)

% sys.save()
% sys.close()

