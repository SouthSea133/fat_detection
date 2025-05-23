clc;clear all;close all;
set(0, "DefaultFigureWindowStyle", "docked");
%% Input
raw_name = dir('./log/export_raw.csv');
raw_signal = readtable([raw_name.folder '\' raw_name.name]);
%% Parameters
filter_order_list = 1:10;
interp_type_list = {'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', 'spline'};
flow_list = 35:45;
fhigh_list = 55:65;
flist = zeros(length(flow_list)*length(fhigh_list), 1);
k = 0;
for i = 1:length(flow_list)
    for ii = 1:length(fhigh_list)
        k = k + 1;
        flist(k,1) = flow_list(i);
        flist(k,2) = fhigh_list(ii);
    end
end
num_movmean_list    = 3:23;
%% Paralell poll setup
totalTasks = length(num_movmean_list);
%% Run Monte Carlo
% numMc = length(f_list);
for i = 1:totalTasks
    params.fs = 1000e3; % Tần số lấy mẫu 1 MHz
    params.flow = 40e3; % Tần số cắt thấp 40 kHz
    params.fhigh = 60e3; % Tần số cắt cao 60 kHz
    params.N_interp = 1000; % Số mẫu nội suy mong muốn
    params.interp_type = 'v5cubic';
    params.filter_order = 5;
    params.sub_min_thresh = 20/1e6;%20us
    params.num_movmean    = num_movmean_list(i);
    % Algorithm
    [fat_time, rec] = process_fat_detect(raw_signal, params);
    std_fat_time = std(fat_time(2000:end))*1e6;

    % Output
    result.mc_input = params;
    result.output = std_fat_time;
    result.fat_time = fat_time;
end
