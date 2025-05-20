clc;clear all;close all;
set(0, "DefaultFigureWindowStyle", "docked");
%% Tạo dữ liệu mẫu để kiểm chứng
fs = 1e6; % Tần số lấy mẫu 1 MHz
t = 0:1/fs:0.001; % 1 ms tín hiệu

% Tạo sóng Berlage (mô phỏng sóng S)
fc = 40e3; % Tần số trung tâm 40 kHz
alpha = 50; % Hệ số suy giảm
delay = 200e-6; % Thời gian trễ 200 μs
source_wavelet = @(t) (t >= 0).* (t.^2) .* exp(-alpha*t) .* sin(2*pi*fc*t);

% Tạo tín hiệu mẫu
signal = zeros(size(t));
signal(t >= delay) = source_wavelet(t(t >= delay) - delay);

% Thêm nhiễu Gaussian
noise_level = 0.2;
signal_noisy = signal + noise_level * randn(size(signal));

% Thêm thành phần tần số cao và thấp không mong muốn
signal_noisy = signal_noisy + 0.1*sin(2*pi*10e3*t) + 0.05*sin(2*pi*500e3*t);

%% Áp dụng giải thuật
flow = 30e3; % Tần số cắt thấp 30 kHz
fhigh = 60e3; % Tần số cắt cao 60 kHz
manual_window = [150e-6, 250e-6]; % Khoảng thời gian mong đợi FAT

[fat_time, filtered_signal, operator, correlation] = detect_first_arrival(...
    signal_noisy, fs, flow, fhigh, manual_window);

%% Hiển thị kết quả
figure;

% Tín hiệu gốc
subplot(4,1,1);
plot(t*1e6, signal_noisy);
title('Tín hiệu gốc có nhiễu');
xlabel('Thời gian (μs)');
ylabel('Biên độ');
grid on;

% Tín hiệu sau lọc
subplot(4,1,2);
plot(t*1e6, filtered_signal);
title('Tín hiệu sau lọc thông dải');
xlabel('Thời gian (μs)');
ylabel('Biên độ');
grid on;

% Toán tử ước lượng được
subplot(4,1,3);
plot((0:length(operator)-1)/fs*1e6, operator);
title('Toán tử ước lượng bằng phân tích phổ Kolmogorov');
xlabel('Thời gian (μs)');
ylabel('Biên độ');
grid on;

% Kết quả tương quan chéo và FAT
subplot(4,1,4);
plot(t*1e6, correlation);
hold on;
plot(fat_time*1e6, max(correlation), 'ro', 'MarkerSize', 10);
title(['Kết quả tương quan chéo - FAT = ' num2str(fat_time*1e6) ' μs']);
xlabel('Thời gian (μs)');
ylabel('Tương quan');
xlim([0 300]);
grid on;

%% So sánh với giá trị thực
fprintf('Thời gian đến đầu tiên (FAT):\n');
fprintf('  Giá trị thực: %.2f μs\n', delay*1e6);
fprintf('  Giá trị ước lượng: %.2f μs\n', fat_time*1e6);
fprintf('  Sai số: %.2f μs\n', abs(delay-fat_time)*1e6);