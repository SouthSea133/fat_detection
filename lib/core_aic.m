function [AIC, minAICIndex] = core_aic(signal_process)   
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

    % 8. Setting the stop index to ignore the ring down
    for sdx = 1:size(signal_process, 1)
        [~, i_stop] = max( abs( signal_process(sdx,:) ) );
        AIC(sdx,i_stop+1:end) = NaN;
    end

    % 9. Get signal arrival from minimum AIC, constrained to be less than i_stop
    AIC(AIC == -inf) = nan;
    [~, minAICIndex] = min(AIC, [], 2, 'omitnan');

end