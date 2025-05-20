clc;clear all;close all;
set(0, "DefaultFigureWindowStyle", "docked");
%% Input
raw = readtable("export_raw.csv");

raw_size = size(raw);

for i = 1:raw_size(1)
    value = rows2vars(raw(i,:));
    data = value.Var1';
    [AIC, minAICIndex] = core_aic(data);
    

    if (AIC(200) ~= inf)
        figure;
        subplot(2, 1, 1);
        plot(data', 'r', 'linewidth', 1.5);
        xline(minAICIndex);
        title('Signal');
        xlim([-Inf, length(data)]);
        xlabel('Sample Index');
    
        subplot(2, 1, 2);
        hold on;
        plot(AIC', 'k-', 'linewidth', 1.5);
        h = xline(minAICIndex, 'k--');
        title('AIC');
        xlim([-Inf, length(data)]);
        xlabel('Sample Index');
        legend(h, {'Minimum AIC'});
    end
end