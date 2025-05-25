function energy = core_tkeo(signal)
    signal = signal(:); % Ensure column vector
    N = length(signal);
    % Compute TKEO for points 2 to N-1
    energy = signal(2:N-1).^2 - signal(1:N-2).*signal(3:N);
    % Pad with zeros to maintain length N
    energy = [0; energy; 0];
end