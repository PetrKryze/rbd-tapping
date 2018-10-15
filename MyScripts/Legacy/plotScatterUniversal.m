%% Universal scatter plotting script
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
clc
close all
clear
figure

setLabels = {'RBD','BIO','CON'};
colors = {'blue','red','black'};
vscale = 0.25;

for i = 1:length(setLabels)
    load(sprintf('processed_%s.mat',setLabels{i}))
    
    % gaussTest(xData);
    % gaussTest(yData);
    
    fprintf("Normalising data...\n\n")
    ndata = normalise([xData ; yData]);
    
    mx = mean(ndata(1,:));
    my = mean(ndata(2,:));
    
    [V, ~] = getPCA(ndata);
    scatter(ndata(1,:),ndata(2,:),140,colors{i},'.')
    hold on
    scatter(mx,my,140,colors{i},'x')
    quiver(mx,my,V(1,1),V(2,1),vscale,colors{i},'LineWidth',1,'HandleVisibility','off');
    quiver(mx,my,V(1,2),V(2,2),vscale,colors{i},'LineWidth',1,'HandleVisibility','off');
    fprintf("---------------\n")
end

grid on
grid minor

xlim([-0.2 1.2])
ylim([-0.2 1.2])
xlabel(sprintf('X Parameter - %s [-]', params{1}))
ylabel(sprintf('Y Parameter - %s [-]', params{2}))
title(sprintf('RBD + BIO + CON data - %s / %s', params{1}, params{2}))
legend('RBD','RBD mean','BIO','BIO mean','CON','CON mean','Location','best')
set(gcf, 'Position', [50, 120, 800, 650])

hold off

function [] = gaussTest(data)
    [H, P] = jbtest(data);
    
    if H
        fprintf("Rejecting that data is Gaussian with p-value of %f\n", P)
    else
        fprintf("Data is Gaussian with p-value of %f\n", P)
    end
    
    fprintf("\n")
end
