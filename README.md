<p align="center">
  <a href="https://gave92.github.io/Matsim/">
    <img src="https://github.com/gave92/matsim/blob/master/docs/images/matsim-logo.png?raw=true" width="170" />
  </a>

  <h3 align="center">Matsim</h3>

  <p align="center">
    A sleek, intuitive interface for building Simulink models from a Matlab script.
    <br>
    <a href="https://gave92.github.io/Matsim/"><strong>Explore Matsim docs »</strong></a>
    <br>
    <br>
    <a href="https://github.com/gave92/Matsim/issues/new?template=bug_report.md">Report bug</a>
    ·
    <a href="https://github.com/gave92/Matsim/issues/new?template=feature_request.md&labels=enhancement">Request feature</a>
  </p>
</p>

Matsim is a high level interface to create Simulink models from a [Matlab](https://www.mathworks.com/) script. Matsim is a wrapper around the standard [simulink API](https://it.mathworks.com/help/simulink/ug/approach-modeling-programmatically.html) that makes building a simulink model programmatically much faster.

![logo](https://img.shields.io/badge/license-MIT-blue.svg)

## Key features
* **Automatic layout** (no need to specify block positions!)
* **Intuitive interface** (you can "add", "subtract", "multiply", ... simulink blocks)
* **Extensible library** (easily add new blocks from your custom libraries)

| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Source&nbsp;script&nbsp;(.m)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |  Resulting model | Notes |
:-------------------------:|:-------------------------:|:-------------------------:
`c = Constant(1)` | <img src="https://github.com/gave92/matsim/blob/master/docs/images/readme/readme_1.PNG?raw=true" height="80" /> | Create a Constant block with value 1
`res = a+b` | <img src="https://github.com/gave92/matsim/blob/master/docs/images/readme/readme_2.PNG?raw=true" height="80" /> | Create an Add block and connect its inputs to blocks `a` and `b`
`res = [a,b]` | <img src="https://github.com/gave92/matsim/blob/master/docs/images/readme/readme_3.PNG?raw=true" height="80" /> | Create an Mux block and connect its inputs to blocks `a` and `b`
`res = Max(a,b)` | <img src="https://github.com/gave92/matsim/blob/master/docs/images/readme/readme_4.PNG?raw=true" height="80" /> | Create an MinMax block and connect its inputs to blocks `a` and `b`
`res = 1 - u1./(u2.*u3)` | <img src="https://github.com/gave92/matsim/blob/master/docs/images/readme/readme_5.PNG?raw=true" height="80" /> | Create a group of simulink blocks that computes a complex expression
`Scope(Gain(FromWorkspace('var'),'value',0.5))` | <img src="https://github.com/gave92/matsim/blob/master/docs/images/readme/readme_6.PNG?raw=true" width="150" /> | Easily combine blocks

## Installation

The automatic layout feature relies on [GraphViz](https://www.graphviz.org/), which you need to install separately.

1. Install [GraphViz](https://www.graphviz.org/download/) and add it to the system PATH
2. Download and extract the Matsim package (from [File Exhange](https://it.mathworks.com/matlabcentral/fileexchange/68436-matsim) or from here)
3. Add Matsim folder (and subfolders) to the Matlab path

## Quick guide

Quick example to get started. For more check the [tests](https://github.com/gave92/Matsim/tree/master/tests) folder.

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
```

#### 3. Connect and layout the model

```matlab
simlayout(sys.handle)                         % Connect and layout the model
```

#### 4. Simulate the system

```matlab
V_x = [0:0.1:10;linspace(5,20,101)]';         % Define input variables
W_r = [0:0.1:10;linspace(5,23,101)/0.32]';
simOut = sys.run('tstop',10).Logs;            % Simulate the system
```

## Known issues
The first time you execute a script you might get this error:
> Attempt to modify 'simulink' which is a locked (read-only) library

Keep calm and execute the script again.

© Copyright 2017 - 2018 by Marco Gavelli
