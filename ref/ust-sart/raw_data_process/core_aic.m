function [AIC, minAICIndex] = core_aic(data, IgnoreRingDown)
if (nargin < 2)
    IgnoreRingDown = true;
end
% Calculate the AIC
AIC = inf(size(data));
Nt = size(data, 2);
for k = 2:(Nt - 1)
    AIC(:, k) = k .* log(...
                          var(data(:, 1:k), 0, 2) ...
                        ) + ...
     (Nt - k - 1) .* log(...
                          var(data(:, k + 1:end), 0, 2) ...
                        );
end

% % Setting the stop index to ignore the ring down
if IgnoreRingDown
    for sdx = 1:size(data, 1)
        [~, i_stop] = max( abs( data(sdx,:) ) );
        AIC(sdx,i_stop+1:end) = NaN;
    end
end

% Get signal arrival from minimum AIC, constrained to be less than i_stop
AIC(AIC == -inf) = nan;
[~, minAICIndex] = min(AIC, [], 2, 'omitnan');
end