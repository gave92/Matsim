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
test = 'subsystems';
feval(['test','_',lower(test)],sys)

%% Layout & connect
simlayout(sys.handle)

