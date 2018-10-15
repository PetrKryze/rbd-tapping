function [labels, fdataWorse] = getMaxOfMinHand(fdata)
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
Nfiles = length(fdata);
labels = cell(1,Nfiles);
fdataWorse = zeros(1,Nfiles);

for i = 1:Nfiles
    Lfreq = zeros(1,2);
    Pfreq = zeros(1,2);
    
    % Left hand, 1st and 2nd measurement
    Lfreq(1) = fdata(1,i); % find(strcmp(V, 'L1')) == 1
    Lfreq(2) = fdata(2,i); % find(strcmp(V, 'L2')) == 2
    % Right hand, 1st and 2nd measurement
    Pfreq(1) = fdata(5,i); % find(strcmp(V, 'P1')) == 5
    Pfreq(2) = fdata(6,i); % find(strcmp(V, 'P2')) == 6
    
    Lfreq = cleanZeroValues(Lfreq);
    Pfreq = cleanZeroValues(Pfreq);
            
    if (all(isnan(Lfreq(:))) && all(isnan(Pfreq(:)))) % No data available, skipping
        labels(i) = {"NaN"};
        fdataWorse(i) = NaN;
        continue;
    elseif ( all(isnan(Lfreq(:))) || mean(Pfreq(~isnan(Pfreq))) <= mean(Lfreq(~isnan(Lfreq))) )
        % Right hand worse or left hand data not available
        [fdataWorse(i), ix] = max(Pfreq); % Take maximum of a worse hand
        labels(i) = {sprintf("P%d",ix)};
    elseif ( all(isnan(Pfreq(:))) || mean(Lfreq(~isnan(Lfreq))) < mean(Pfreq(~isnan(Pfreq))) )
        % Left hand worse or right hand data not available
        [fdataWorse(i), ix] = max(Lfreq); % Take maximum of a worse hand
        labels(i) = {sprintf("L%d",ix)};
    end

end

%% Control Plotting
% figure
% histogram(fdataWorse)
% title("Worse hand tapping frequency data")
% grid on
% grid minor
% ylabel('Frequency - f [Hz]')

end