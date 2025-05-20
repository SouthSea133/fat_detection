function [fat_time, filtered_signal, AIC] = core_fat_detection(signal, fs, flow, fhigh, IgnoreRingDown)
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

    if (nargin <= 4)
        IgnoreRingDown = true;
    end

    % 1. Trend removal (remove DC)
    signal = detrend(signal);
    
    % 2. Pass band Butterworth filter
    [b, a] = butter(4, [flow fhigh]/(fs/2), 'bandpass');
    
    % 3. Apply Filter
    filtered_signal = filtfilt(b, a, signal);

    % 4. Choose the signal process
    signal_process = filtered_signal;

    % 5. Calculate the AIC
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

    % 6. Setting the stop index to ignore the ring down
    if IgnoreRingDown
        for sdx = 1:size(signal_process, 1)
            [~, i_stop] = max( abs( signal_process(sdx,:) ) );
            AIC(sdx,i_stop+1:end) = NaN;
        end
    end

    % 7. Get signal arrival from minimum AIC, constrained to be less than i_stop
    AIC(AIC == -inf) = nan;
    [~, minAICIndex] = min(AIC, [], 2, 'omitnan');
    fat_time = minAICIndex * 1/fs;
end