clearvars
close all
clc

f = figure;
ax = axes;
L = 160*membrane(1,100);
s = surface(L);
s.EdgeColor = 'none';
view(3)
ax.XLim = [1 201];
ax.YLim = [1 201];
ax.ZLim = [-53.4 160];
ax.CameraPosition = [-145.5 -229.7 283.6];
ax.CameraTarget = [77.4 60.2 63.9];
ax.CameraUpVector = [0 0 1];
ax.CameraViewAngle = 36.7;
ax.Position = [0 0 1 1];
ax.DataAspectRatio = [1 1 .9];
axis off
f.Color = 'white';
length = 100;
red = [1, 0, 0];
pink = [255, 192, 203]/255;
colors_p = [linspace(red(1),pink(1),length)', linspace(red(2),pink(2),length)', linspace(red(3),pink(3),length)'];
colormap(colors_p)
% print(gcf,'matsim-logo.png','-dpng','-r300');
