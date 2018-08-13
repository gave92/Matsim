clearvars
close all
clc

% Show text?
show_text = true;

if show_text
    f = figure('Units','norm','Position',[0.05,0.2,0.9,0.6]);
else
    f = figure;
end
f.Color = 'white';

% Create axes for surface
if show_text
    ax = axes('Position',[0.22 0 1 1]);
else
    ax = axes('Position',[0 0 1 1]);
end
ax.XLim = [1 201];
ax.YLim = [1 201];
ax.ZLim = [-53.4 160];
hold on
axis off
view(3)

% Create red surface
L = 160*membrane(1,100);
s = surface(L);
s.EdgeColor = 'none';

% Set camera position
ax.CameraPosition = [-145.5 -229.7 283.6];
ax.CameraTarget = [77.4 60.2 63.9];
ax.CameraUpVector = [0 0 1];
ax.CameraViewAngle = 36.7;
ax.DataAspectRatio = [1 1 .9];

% Set colormap
length = 100;
red = [1, 0, 0];
pink = [255, 192, 203]/255;
colors_p = [linspace(red(1),pink(1),length)', linspace(red(2),pink(2),length)', linspace(red(3),pink(3),length)'];
colormap(colors_p)

% Create second axes behind the other
if show_text
    ax = axes('Position',[0.22 0 1 1]);
else
    ax = axes('Position',[0 0 1 1]);
end
ax.XLim = [-20 201];
ax.YLim = [1 201];
ax.ZLim = [-53.4 160];
uistack(ax,'bottom');
hold on
axis off
view(3)

% Set camera position
ax.CameraPosition = [35.5 -229.7 183.6];
ax.CameraTarget = [82.4 60.2 63.9];
ax.CameraUpVector = [0 0 1];
ax.CameraViewAngle = 50.7;

% Plot rectangle
x = [0 100 100 0]-20;
z = [0 0 100 100];
y = [0 0 0 0]+200;
ct = [[226 145 59]/255;[228 95 33]/255;[226 145 59]/255;[226 194 84]/255];
csq(1,1:4,1:3) = ct;
sq = patch(x,y,z,csq);
sq.EdgeColor = 'none';

% Plot triangle
x = [0 100 50]+20;
z = [0 0 100]+40;
y = [0 0 0]+200;
ct = [[38 86 137]/255;[75 142 187]/255;[89 163 205]/255];
ctr(1,1:3,1:3) = ct;
tr = patch(x,y,z,ctr);
tr.EdgeColor = 'none';

% Add text
if show_text
    ax = axes('Position',[0 0 1 1]);
    hold on
    axis off
    txt = text(0.05,0.5,'Matsim');
    set(txt,'FontName','Segoe UI Symbol')
    set(txt,'FontSize',140)
    set(txt,'Color',[89 89 89]/255)
    
    % Resize text with figure!!
    orig_sz = f.Position;
    f.ResizeFcn = @(src,ev) set(txt,'FontSize',src.Position(3)/orig_sz(3)*140);
end

% Export to PNG
if show_text
    export_fig(f,'matsim-icon.png','-m4','-transparent')
else
    export_fig(f,'matsim-logo.png','-m4','-transparent')
end

