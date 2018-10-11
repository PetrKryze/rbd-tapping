function [] = matchYDataAndSave(labels, yData, xDataRaw, dataset, params)
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
Nfiles = length(yData);
xData = zeros(1,Nfiles);
types = {'L1','L2','LS','LC','P1','P2','PS','PC'};

% Match y-data with x-data from same measurement
for i = 1:Nfiles
    if strcmp(labels{i}, "NaN") % Y-data not available
        xData(i) = NaN;
        yData(i) = NaN;
        continue;
    end
    
    label = char(labels{i});    
    handIdx = find(strcmp(types, label));
    xData(i) = xDataRaw(handIdx,i);  
    
%     if (strcmp(label(1),'L')) % Left hand frequency data
%         if (strcmp(label(2), '1'))
%             xData(i) = xDataRaw(1,i); % L1
%         elseif (strcmp(label(2), '2'))
%             xData(i) = xDataRaw(2,i); % L2
%         end
%     elseif (strcmp(label(1), 'P')) % Right hand frequency data
%         if (strcmp(label(2), '1'))
%             xData(i) = xDataRaw(5,i); % P1
%         elseif (strcmp(label(2), '2'))
%             xData(i) = xDataRaw(6,i); % P2
%         end
%     end
   
end

%% Save the processed data
filename = sprintf("processed_%s",dataset);
save(filename, 'labels', 'xData', 'yData', 'params')

end