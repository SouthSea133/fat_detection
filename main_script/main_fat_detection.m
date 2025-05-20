clc;clear all;close all;
set(0, "DefaultFigureWindowStyle", "docked");
%% Input
raw_name = dir('./log/export_raw_2.csv');
raw = readtable([raw_name.folder '\' raw_name.name]);
raw_size = size(raw);

fs = 400e3; % Tần số lấy mẫu 400 KHz
t = linspace(0,1e-3,raw_size(2));% 1 ms tín hiệu

%% Algorithm
signal = zeros(raw_size);
filtered_signal = zeros(raw_size);
AIC = zeros(raw_size);
fat_time = zeros(raw_size(1),1);

flow = 40e3; % Tần số cắt thấp 40 kHz
fhigh = 60e3; % Tần số cắt cao 60 kHz

for i = 1:raw_size(1)
    value = rows2vars(raw(i,:));
    signal(i,:) = value.Var1';

    [fat_time(i), filtered_signal(i,:), AIC(i,:)] = core_fat_detection(...
    signal(i,:), fs, flow, fhigh, true);
end
%% Plot
clc;close all;
% data_plot_list = [3, 50, 100, 400, 600, 1000, 1500, 2000, 3000, 4000];
data_plot_list = 3960:3980;
% data_plot_list = 9960:9980;
for num_data = data_plot_list
    % data_ = signal(num_data,:)';
    data_ = filtered_signal(num_data,:)';
    minAICTime_ = fat_time(num_data)*1e6;
    AIC_ = AIC(num_data,:)';
    
    figure('Name',"FAT detection");
    sgtitle(['Data number ' num2str(num_data)]);
    subplot(2, 1, 1);
    plot(t*1e6, data_', 'r', 'linewidth', 1.5);
    xline(minAICTime_);
    title('Signal');
    xlim([-Inf, raw_size(2)*1/fs*1e6]);
    xlabel('Time (us)');
    
    subplot(2, 1, 2);
    hold on;
    plot(t*1e6, AIC_, 'k-', 'linewidth', 1.5);
    h = xline(minAICTime_, 'k--');
    title('AIC');
    xlim([-Inf, raw_size(2)*1/fs*1e6]);
    xlabel('Time (us)');
    legend(h, {'Minimum AIC'});
    fprintf('FAT number %d: %.1f us\n',num_data, minAICTime_);
end

    figure('Name',"FAT detection summary");
    plot(fat_time*1e6, 'linewidth', 1.5);
    xlim([1, raw_size(1)]);
    xlabel('Data number');
    ylabel('FAT time (us)');
    title('FAT detection summary ');