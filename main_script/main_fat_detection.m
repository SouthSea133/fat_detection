clc;clear all;close all;
set(0, "DefaultFigureWindowStyle", "docked");
%% Input
raw_name = dir('./log/DataSection_Section_1-2_2025.06.04_22.58.53.csv');
raw_signal = readtable([raw_name.folder '\' raw_name.name]);
raw_signal(:,1:3) = [];
%% Parameters
params.fs = 1000e3; % Tần số lấy mẫu 2 MHz
params.flow = 40e3; % Tần số cắt thấp 40 kHz
params.fhigh = 60e3; % Tần số cắt cao 60 kHz
params.N_interp = 1000; % Số mẫu nội suy mong muốn
params.interp_type = 'spline';% Phương pháp nội suy
params.filter_order = 5;% Số bậc của bộ lọc thông dải
params.window_length_s = 150/1e6;%us % Window time quanh điểm min của AIC để chọn fat 
params.fat_time_thresh = 30/1e6;%us % Tham số thể hiện độ mức độ biến đổi fat hệ thống, số càng lớn thì hệ thống ước lượng FAT có quán tính càng lớn, càng ì ạch, không dễ thay đổi.
%% Algorithm
[fat_time, rec] = process_fat_detection(raw_signal, params);
%% Plot
clc;close all;
raw_data_size = size(raw_signal);
% data_plot_list = 1:raw_data_size(1);
% data_plot_list = [3, 50, 100, 400, 600, 1000, 1500, 2000, 3000, 4000];
data_plot_list = 460:480;
% data_plot_list = 9960:9980;

t = linspace(1e-3/params.N_interp,1e-3,params.N_interp);% 1 ms tín hiệu
interp_data_size = params.N_interp;
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

    pause(0.05);

    if (rem(num_data, 300) == 0)
        close all;
    end
end

    figure('Name',"FAT detection summary");
    plot(fat_time*1e6, 'linewidth', 1.5);
    xlim([1, raw_data_size(1)]);
    xlabel('Data number');
    ylabel('FAT time (us)');
    title('FAT detection summary ');

    % fprintf('FAT Std: %.4f us\n',std(fat_time(5000:9000))*1e6);
    % fprintf('FAT Std: %.4f us\n',std(fat_time(2000:end))*1e6);
    fprintf('FAT Std: %.4f us\n',std(fat_time)*1e6);