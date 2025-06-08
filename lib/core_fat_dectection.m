function [fat_time, rec] = core_fat_dectection(signal, params, fat_time_)
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

    %% Persistent value
    persistent tkeo_thresh
    %% Input
    fs = params.fs;
    flow           = params.flow; 
    fhigh          = params.fhigh; 
    N_interp       = params.N_interp; 
    interp_type    = params.interp_type; 
    filter_order   = params.filter_order;
    window_length  = params.window_length_s*fs;
    fat_time_thresh = params.fat_time_thresh;

    % 1. Trend removal (remove DC)
    signal = detrend(signal);

    % 2. Denoise Signals
    signal = wdenoise(signal, 5, 'Wavelet', 'db4', 'DenoisingMethod', 'SURE', 'ThresholdRule', 's');

    % 3. Interpolate to increase sample
    t_before = linspace(1e-3/size(signal,2),1e-3,size(signal,2));% 1 ms tín hiệu
    t_after = linspace(1e-3/N_interp,1e-3,N_interp);% 1 ms tín hiệu
    signal_interp = interp1(t_before, signal, t_after, interp_type);

    % 4. Pass band Butterworth filter
    [b, a] = butter(filter_order, [flow fhigh]/(fs/2), 'bandpass');
    
    if any(~isfinite(signal_interp))
        % warning('Tín hiệu chứa Inf/NaN. Đang thay thế...');
        signal_interp = fillmissing(signal_interp, 'constant', 0); % Thay thế bằng 0
    end
    % 5. Apply Filter
    filtered_signal = filtfilt(b, a, signal_interp);

    % 6. Choose the signal process
    signal_process = filtered_signal;

    % TKEO energy
    energy = core_tkeo(signal_process);

    % 7. Calculate the AIC
    [AIC, minAICIndex] = core_aic(signal_process);

    if (isempty(tkeo_thresh))
        tkeo_thresh = energy(minAICIndex);
    elseif (abs(minAICIndex*1/fs - fat_time_) < fat_time_thresh)
        tkeo_thresh = energy(minAICIndex);
    end

    % window_length = 200;
    if (minAICIndex > window_length)
        tmp = find(energy(minAICIndex-window_length:minAICIndex+window_length) >= tkeo_thresh, 1, "first");
        if (~isempty(tmp))
            TKEO_index = minAICIndex - window_length + tmp;
        else
            TKEO_index = minAICIndex;
        end
    else
        TKEO_index = minAICIndex;
    end
    
    % 10. Post process AIC

    true_min = TKEO_index;

    fat_time = true_min * 1/fs;

    if(abs(fat_time - fat_time_) < fat_time_thresh)
        fat_time = fat_time_;
    end

    rec.filtered_signal = filtered_signal;
    rec.AIC = AIC;
    rec.tkeo_energy = energy';
end