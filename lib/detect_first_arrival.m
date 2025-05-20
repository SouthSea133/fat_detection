function [fat_time, filtered_signal, operator, correlation] = detect_first_arrival(signal, fs, flow, fhigh, manual_window)
    % DETECT_FIRST_ARRIVAL Xác định thời gian đến đầu tiên từ tín hiệu sóng S siêu âm
    % Input:
    %   - signal: Tín hiệu đầu vào
    %   - fs: Tần số lấy mẫu (Hz)
    %   - flow, fhigh: Tần số cắt thấp và cao của bộ lọc thông dải (Hz)
    %   - manual_window: Khoảng thời gian [t1 t2] để tìm FAT (giây)
    % Output:
    %   - fat_time: Thời gian đến đầu tiên (giây)
    %   - filtered_signal: Tín hiệu sau khi lọc
    %   - operator: Toán tử ước lượng được
    %   - correlation: Kết quả tương quan chéo
    
    % 1. Loại bỏ trend (thành phần DC)
    signal = detrend(signal);
    
    % 2. Thiết kế bộ lọc thông dải Butterworth
    [b, a] = butter(4, [flow fhigh]/(fs/2), 'bandpass');
    
    % 3. Áp dụng bộ lọc
    filtered_signal = filtfilt(b, a, signal);
    
    % 4. Ước lượng toán tử bằng phân tích phổ Kolmogorov
    operator = kolmogorov_factorization(filtered_signal);
    
    % 5. Tính tương quan chéo giữa tín hiệu đã lọc và toán tử
    correlation = xcorr(filtered_signal, operator);
    correlation = correlation(length(filtered_signal):end); % Chỉ lấy phần không âm
    
    % 6. Xác định FAT trong khoảng manual_window
    t = (0:length(filtered_signal)-1)/fs;
    window_idx = find(t >= manual_window(1) & t <= manual_window(2));
    [~, max_idx] = max(abs(correlation(window_idx)));
    fat_idx = window_idx(1) + max_idx - 1;
    fat_time = t(fat_idx);
end

function operator = kolmogorov_factorization(signal)
    % KOLMOGOROV_FACTORIZATION Ước lượng toán tử minimum phase từ tín hiệu
    % bằng phân tích phổ Kolmogorov
    
    N = length(signal);
    fft_signal = fft(signal);
    power_spectrum = abs(fft_signal).^2;
    
    % Tính log phổ công suất
    log_spectrum = log(power_spectrum);
    
    % Tính biến đổi Hilbert của log phổ công suất
    hilbert_log = imag(hilbert(log_spectrum));
    
    % Tạo phổ minimum phase
    min_phase_spectrum = exp(log_spectrum + 1i*hilbert_log);
    
    % Biến đổi ngược về miền thời gian
    operator = real(ifft(min_phase_spectrum));
    
    % Chuẩn hóa toán tử
    operator = operator / max(abs(operator));
end