<img src="https://github.com/gave92/matsim/blob/master/matsim-icon.png?raw=true" width="150" />

# Matsim: A Matlab/Simulink interface

![logo](https://img.shields.io/badge/license-MIT-blue.svg)

Matsim is a high level interface to create Simulink models from a [Matlab](https://www.mathworks.com/) script. Matsim is a wrapper around the standard [simulink API](https://it.mathworks.com/help/simulink/ug/approach-modeling-programmatically.html) that makes building a simulink model programmatically much faster.

## Key features
* **Automatic layout** (no need to specify block positions!)
* **Intuitive interface** (you can "add","subtract","multiply",... simulink blocks)
* **Extensible library** (easily add new blocks from your custom libraries)

| Source script (.m)             |  Resulting model |
:-------------------------:|:-------------------------:
`c = Constant(1)` | Create a Constant block with value 1
`res = a+b` | Create an Add block and connect its inputs to blocks `a` and `b`
`res = [a,b]` | Create an Mux block and connect its inputs to blocks `a` and `b`
`res = IF(a>0,a+b,a-b)` | Create a Switch block that if `a>0` passes the result of `a+b`
`res = 1 - u1./(u2.*u3)` | Create a group of simulink blocks that computes a complex expression

## Installation

The automatic layout feature relies on [GraphViz](https://www.graphviz.org/), which you need to install separately.

1. Install GraphViz and add it to the system PATH
2. Download and extract the Matsim package
3. Add Matsim folder (and subfolders) to the Matlab path

## Quick guide

Quick example to get started.

#### 1. Create or load a simulink model

```matlab
sys = simulation.load('my_model');            % Create or load a model named 'my_model'
sys.setSolver('Ts',0.01,'DiscreteOnly',true)  % Set solver for the model
sys.clear()                                   % Delete all blocks
sys.show()                                    % Show the model
```

#### 2. Create blocks

```matlab
Vx = FromWorkspace('V_x');                    % Add FromWorkspace and Constant blocks
Wr = FromWorkspace('W_r');
Rr = Constant(0.32);

slip = 1 - Vx./(Wr.*Rr);                      % Evaluate complex mathematical expression
sys.log(slip,'slip')                          % Log the output of the "slip" block

s = Scope(slip);                              % Create and open scope block
s.open()

simlayout(sys.handle)                         % Connect and layout model
```

#### 3. Simulate the system

```matlab
V_x = [0:0.1:10;linspace(5,20,101)]';         % Define input variables
W_r = [0:0.1:10;linspace(5,23,101)/0.32]';
simOut = sys.run('tstop',10).Logs;            % Simulate the system
```

© Copyright 2017 - 2018 by Marco Gavelli
