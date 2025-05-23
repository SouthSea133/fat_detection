function [fat_time, rec] = core_hilber_parabolic(signal, params)
    % DETECT_FIRST_ARRIVAL Xác định thời gian đến đầu tiên từ tín hiệu sóng S siêu âm
    % Input:
    %   - signal: Tín hiệu đầu vào
    %   - fs: Tần số lấy mẫu (Hz)
    %   - flow, fhigh: Tần số cắt thấp và cao của bộ lọc thông dải (Hz)
    %   - manual_window: Khoảng thời gian [t1 t2] để tìm FAT (giây)
    % Output:
    %   - fat_time: Thời gian đến đầu tiên (giây)
    %   - filtered_signal: Tín hiệu sau khi lọc
    %   - AIC: Toán tử ước lượng được

    %% Input
    % fs = params.fs;
    % flow           = params.flow; 
    % fhigh          = params.fhigh; 
    % N_interp       = params.N_interp; 
    % interp_type    = params.interp_type; 
    % filter_order   = params.filter_order;
    % sub_min_thresh = params.sub_min_thresh;
    % num_movmean    = params.num_movmean;

    % Apply Hilbert transform
    signal_h = hilbert(signal);
    rec.envelope = abs(signal_h);

    
    % Estimate noise level and set dynamic threshold
    threshold = max(params.threshold, 0.05*max(envelope)); % Đảm bảo ngưỡng tối thiểu
    
    % Find first index where envelope > threshold
    idx_fat = find(envelope > threshold, 1, 'first');
    if isempty(idx_fat)
        error('Threshold not exceeded');
    end
    t_fat = t(idx_fat);
    fprintf('First arrival time (without interpolation): %.2f us\n', t_fat * 1e6);
    
    % Parabolic interpolation
    if idx_fat > 1 && idx_fat < N
        t1 = t(idx_fat-1);
        t2 = t(idx_fat);
        t3 = t(idx_fat+1);
        y1 = envelope(idx_fat-1);
        y2 = envelope(idx_fat);
        y3 = envelope(idx_fat+1);
        
        % Fit parabola: y = a*t^2 + b*t + c
        A = [t1^2, t1, 1; 
             t2^2, t2, 1; 
             t3^2, t3, 1];
        coeffs = A \ [y1; y2; y3];
        a = coeffs(1);
        b = coeffs(2);
        c = coeffs(3);
        
        % Solve a*t^2 + b*t + (c - threshold) = 0
        d = c - threshold;
        poly = [a, b, d];
        roots_t = roots(poly);
        
        % Find root between t1 and t2
        valid_roots = roots_t((roots_t >= t1) & (roots_t <= t2));
        if ~isempty(valid_roots)
            fat_time = min(valid_roots); % Lấy giá trị nhỏ nhất nếu có nhiều nghiệm
            fprintf('First arrival time (with parabolic interpolation): %.2f us\n', fat_time * 1e6);
        else
            fprintf('No valid root found between t1 and t2, using non-interpolated time.\n');
            fat_time = t_fat;
            fprintf('First arrival time (fallback): %.2f us\n', fat_time * 1e6);
        end
    else
        fprintf('Cannot perform interpolation, idx_fat is at edge, using non-interpolated time.\n');
        fat_time = t_fat;
        fprintf('First arrival time (fallback): %.2f us\n', fat_time * 1e6);
    end
end