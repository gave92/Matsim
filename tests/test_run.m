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
[script_path,script_name] = fileparts(which('test_run'));
test_files = dir(fullfile(script_path,'*.m'));
test_names = setdiff(strrep({test_files.name},'.m',''),script_name);
test_numbered = arrayfun(@(i) sprintf('%d. %s',i,test_names{i}),1:length(test_names),'uni',0);
fprintf('Available tests:\n\t%s\n',strjoin(test_numbered,'\n\t'))
test = input('Select test: ','s');
if ~isnan(str2double(test))
    feval(test_names{str2double(test)},sys)
else
    feval(lower(test),sys)
end

%% Layout & connect
sys.layout()

