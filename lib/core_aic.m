function [fat_time, rec] = core_aic(signal, params, fat_time_)
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
    fs = params.fs;
    flow           = params.flow; 
    fhigh          = params.fhigh; 
    N_interp       = params.N_interp; 
    interp_type    = params.interp_type; 
    filter_order   = params.filter_order;
    sub_min_thresh = params.sub_min_thresh;
    fat_time_thresh = params.fat_time_thresh;

    % 1. Trend removal (remove DC)
    signal = detrend(signal);

    % 2. Interpolate to increase sample
    t_before = linspace(1e-3/size(signal,2),1e-3,size(signal,2));% 1 ms tín hiệu
    t_after = linspace(1e-3/N_interp,1e-3,N_interp);% 1 ms tín hiệu
    signal_interp = interp1(t_before, signal, t_after, interp_type);

    % 3. Pass band Butterworth filter
    [b, a] = butter(filter_order, [flow fhigh]/(fs/2), 'bandpass');
    
    if any(~isfinite(signal_interp))
        % warning('Tín hiệu chứa Inf/NaN. Đang thay thế...');
        signal_interp = fillmissing(signal_interp, 'constant', 0); % Thay thế bằng 0
    end
    % 4. Apply Filter
    filtered_signal = filtfilt(b, a, signal_interp);

    % 5. Choose the signal process
    signal_process = filtered_signal;

    % 6. Calculate the AIC
    AIC = inf(size(signal_process));
    Nt = size(signal_process, 2);
    for k = 2:(Nt - 1)
        AIC(:, k) = k .* log(...
                              var(signal_process(:, 1:k), 0, 2) ...
                            ) + ...
         (Nt - k - 1) .* log(...
                              var(signal_process(:, k + 1:end), 0, 2) ...
                            );
    end

    % 7. Setting the stop index to ignore the ring down
    for sdx = 1:size(signal_process, 1)
        [~, i_stop] = max( abs( signal_process(sdx,:) ) );
        AIC(sdx,i_stop+1:end) = NaN;
    end

    % 8. Get signal arrival from minimum AIC, constrained to be less than i_stop
    AIC(AIC == -inf) = nan;
    [~, minAICIndex] = min(AIC, [], 2, 'omitnan');
    
    % 9. Post process AIC
    min_locs = find(islocalmin(AIC)); % Tìm vị trí của các điểm cực trị địa phương
    sub_idx_min = minAICIndex - min_locs; % Hiệu giữa điểm cực tiểu với các điểm cực trị địa phương
    sub_idx_thresh = sub_min_thresh*fs;
    true_min = find((sub_idx_min > 0) & (sub_idx_min < sub_idx_thresh)); % > 0 nghĩa là đứng trước điểm cực tiểu, < sub_idx_thresh nghĩa là không cách xa điểm cực tiểu sub_idx_thresh*dt (us)
    sub_idx = 0;
    if (true_min)
        minAICIndex = min_locs(true_min(1));
        sub_idx = true_min(1);
    end

    fat_time = minAICIndex(1) * 1/fs;

    if(abs(fat_time - fat_time_) < fat_time_thresh)
        fat_time = fat_time_;
    end

    rec.filtered_signal = filtered_signal;
    rec.AIC = AIC;
    rec.sub_idx = sub_idx;
end