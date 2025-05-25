function [fat_time, rec] = process_hilber_parabolic(raw_signal, params)
%% Initialization
% data_size = [size(raw_signal,1), params.N_interp];
% signal = zeros(size(raw_signal));
% rec.filtered_signal = zeros(data_size);
% rec.AIC = zeros(data_size);
% rec.sub_idx = zeros(data_size(1),1);
% fat_time = zeros(data_size(1),1);

data_size = [size(raw_signal,1), params.N_interp];
% signal = zeros(size(raw_signal));
% rec.filtered_signal = zeros(data_size);
% rec.AIC = zeros(data_size);
% rec.sub_idx = zeros(data_size(1),1);
fat_time = zeros(data_size(1),1);
%% Algorithm
for i = 1:data_size(1)
    value = rows2vars(raw_signal(i,:));
    signal(i,:) = value.Var1';

    [fat_time(i), rec_] = core_fat_dectection(...
    signal(i,:), params);
    rec.filtered_signal(i,:) = rec_.filtered_signal;
    rec.AIC(i,:) = rec_.AIC;
    rec.sub_idx(i,:) = rec_.sub_idx;
end
end