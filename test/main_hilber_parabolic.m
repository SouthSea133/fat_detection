clc;clear all;close all;
set(0, "DefaultFigureWindowStyle", "docked");
%% Input
raw_name = dir('./log/export_raw_2.csv');
raw_signal = readtable([raw_name.folder '\' raw_name.name]);

%% Parameters
% Estimate noise level and set dynamic threshold
noise_region = envelope(1:idx_start-10); % Lấy vùng trước sóng để ước lượng nhiễu
noise_mean = mean(noise_region);
noise_std = std(noise_region);
params.threshold = noise_mean + 3*noise_std; % Ngưỡng = trung bình nhiễu + 3 độ lệch chuẩn
%% Algorithm
[fat_time, rec] = core_hilber_parabolic(raw_signal, params);
%% Plot
clc;close all;
% data_plot_list = [3, 50, 100, 400, 600, 1000, 1500, 2000, 3000, 4000];
data_plot_list = 230:260;
% data_plot_list = 9960:9980;

t = linspace(1e-3/params.N_interp,1e-3,params.N_interp);% 1 ms tín hiệu
interp_data_size = params.N_interp;
raw_data_size = size(raw_signal);
fs = params.fs;
for num_data = data_plot_list
    % data_ = signal(num_data,:)';
    data_ = rec.filtered_signal(num_data,:)';
    minAICTime_ = fat_time(num_data)*1e6;
    AIC_ = rec.AIC(num_data,:)';
    
    figure('Name',"FAT detection");
    sgtitle(['Data number ' num2str(num_data)]);
    ax(1) = subplot(2, 1, 1);
    plot(t*1e6, data_', 'r', 'linewidth', 1.5);
    xline(minAICTime_);
    title('Signal');
    xlim([-Inf, interp_data_size*1/fs*1e6]);
    xlabel('Time (us)');
    
    ax(2) = subplot(2, 1, 2);
    hold on;
    plot(t*1e6, AIC_, 'k-', 'linewidth', 1.5);
    h = xline(minAICTime_, 'k--');
    title('AIC');
    xlim([-Inf, interp_data_size*1/fs*1e6]);
    xlabel('Time (us)');
    legend(h, {'Minimum AIC'});
    fprintf('FAT number %d: %.1f us\n',num_data, minAICTime_);
    linkaxes(ax, 'x');
end

    figure('Name',"FAT detection summary");
    plot(fat_time*1e6, 'linewidth', 1.5);
    xlim([1, raw_data_size(1)]);
    xlabel('Data number');
    ylabel('FAT time (us)');
    title('FAT detection summary ');

    fprintf('FAT Std: %.4f us\n',std(fat_time(230:1660))*1e6);