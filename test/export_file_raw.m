close all;
AIC_energy = zeros(raw_data_size(1), params.N_interp);
minAICIndex_energy = zeros(raw_data_size(1),1);

AIC_envelop = zeros(raw_data_size(1), params.N_interp);
minAICIndex_envelope = zeros(raw_data_size(1),1);
figure();
for i = 1:raw_data_size(1)
    % num = 1;
    data = rec.filtered_signal(i,:);
    
    % plot(rec.tkeo_energy(i,:));hold on;

    [AIC_energy(i,:), minAICIndex_energy(i)] = core_aic(rec.tkeo_energy(i,:));
    [AIC_envelope(i,:), minAICIndex_envelope(i)] = core_aic(rec.envelope(i,:));
end

%%
