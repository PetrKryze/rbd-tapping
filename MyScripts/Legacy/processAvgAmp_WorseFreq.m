function [] = processAvgAmp_WorseFreq(labels, fdata, adata, dataset)
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
Nfiles = length(fdata);
ampData = zeros(1,Nfiles);

% Match frequency data with average amplitude data from same measurement
for i = 1:Nfiles
    if strcmp(labels{i}, "NaN") % Frequency data not available
        ampData(i) = NaN;
        fdata(i) = NaN;
        continue;
    end

    label = char(labels{i});
    if (strcmp(label(1),'L')) % Left hand frequency data
        if (strcmp(label(2), '1'))
            ampData(i) = adata(1,i); % L1
        elseif (strcmp(label(2), '2'))
            ampData(i) = adata(2,i); % L2
        end
    elseif (strcmp(label(1), 'P')) % Right hand frequency data
        if (strcmp(label(2), '1'))
            ampData(i) = adata(5,i); % P1
        elseif (strcmp(label(2), '2'))
            ampData(i) = adata(6,i); % P2
        end
    end

end

%% Control Plotting
% figure
% scatter(ampData,fdata)
% grid on
% grid minor

%% Save the processed data
filename = sprintf("processed%s_AvgAmp_WorseFreq",dataset);
save(filename, 'labels', 'fdata', 'ampData')

end