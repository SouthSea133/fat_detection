close all;
figure();
ax(1) = subplot(411);plot(signal_process');title('signal process');
ax(2) = subplot(412);plot(rec.envelope');title('Envelope');
ax(3) = subplot(413);plot(energy);title('TKEO energy');
ax(4) = subplot(414);plot(AIC');title('AIC');
linkaxes(ax, 'x');

[AIC_energy, minAICIndex_energy] = core_aic(energy'); 

% figure();
% ax(1) = subplot(411);plot(energy);
% ax(2) = subplot(412);plot(AIC_energy');
% ax(3) = subplot(413);plot(diff(energy));
% linkaxes(ax, 'x');


min_locs_AIC = find(islocalmin(AIC)); % Tìm vị trí của các điểm cực trị địa phương cua AIC
max_locs_energy = find(islocalmax(energy)); % Tìm vị trí của các điểm cực trị địa phương cua TKEO energy

min_locs_AIC
max_locs_energy'