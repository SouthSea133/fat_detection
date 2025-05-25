clc;clear all;close all;
set(0, "DefaultFigureWindowStyle", "docked");
%% Input
raw_name = dir('./log/export_raw_2.csv');
raw_signal = readtable([raw_name.folder '\' raw_name.name]);
%% Parameters
filter_order_list = 1:10;
interp_type_list = {'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', 'spline'};
flow_list = 35:45;
fhigh_list = 55:65;
f_list = zeros(length(flow_list)*length(fhigh_list), 1);
k = 0;
for i = 1:length(flow_list)
    for ii = 1:length(fhigh_list)
        k = k + 1;
        f_list(k,1) = flow_list(i);
        f_list(k,2) = fhigh_list(ii);
    end
end
num_movmean_list    = 3:23;
%% Paralell poll setup
totalTasks = length(filter_order_list);
h = waitbar(0, 'Đang xử lý...');
% Tạo Future array
f(1:totalTasks) = parallel.FevalFuture;
%% Run Monte Carlo
% numMc = length(f_list);
for i = 1:totalTasks
    f(i) = parfeval(@doMonte, 1, raw_signal, filter_order_list(i));
end

% Theo dõi tiến trình
completed = 0;
while completed < totalTasks
    % Kiểm tra các tác vụ đã hoàn thành
    completed = sum(strcmp({f.State}, 'finished'));
    
    % Cập nhật waitbar
    waitbar(completed/totalTasks, h, ...
        sprintf('Đã hoàn thành %d/%d', completed, totalTasks));
    
    % Tránh kiểm tra quá thường xuyên
    pause(0.1);
end
% Đóng waitbar
close(h);

value = fetchOutputs(f);
%% Function side
function result = doMonte(raw_signal, mc_input)
    % Param init
    params.fs = 1000e3; % Tần số lấy mẫu 2 MHz
    params.flow = 40e3; % Tần số cắt thấp 40 kHz
    params.fhigh = 60e3; % Tần số cắt cao 60 kHz
    params.N_interp = 1000; % Số mẫu nội suy mong muốn
    params.interp_type = 'spline';
    params.filter_order = mc_input;
    params.sub_min_thresh = 20/1e6;%us 
    params.fat_time_thresh = 30/1e6;%us
    % Algorithm
    [fat_time, ~] = process_fat_detection(raw_signal, params);
    % std_fat_time = std(fat_time(2000:end))*1e6;
    std_fat_time = std(fat_time(5000:9000))*1e6;

    % Output
    result.mc_input = params;
    result.output = std_fat_time;
    result.fat_time = fat_time;
end

