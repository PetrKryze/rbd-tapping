%% Statistic analysis
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
clc
clear
close all
%% Constants
root = 'C:\Users\Petr\Disk Google\Thesis\Matlab';
hands = {'Lmean'; 'Pmean'};
badParams = {'allProps','Data','AmpK','OT','VelON','VelCN','VMax','VMin','Time'};
params = properties(PDDataProp); % Get available properties

%% Preparation
% Cut non-parametric data (time, data, allprops, etc.)
for bp = 1:length(badParams) 
    params(find(strcmp(params,badParams{bp}))) = [];
end

% Load patient datasets
if exist(fullfile(root, 'Data', 'datasets.mat'), 'file')
    load('datasets.mat');
else
    % If not present, perform loading script
    datasets = LoadSaveComplete(params);
end

Nsets = length({datasets.label});
Nparams = length(params);
%% Data extraction
for p = 1:Nparams % Loop thru parameters
    extracted = extractSingleProperty(datasets, p);

    for q = 1:length(hands) % Loop thru hand data
        data = [];
        groups = {};
         
        for r = 1:Nsets % Loop thru datasets
            % Data save info
            selectedParam = datasets(r).param{p};
            selectedDataset = datasets(r).label;
            selectedHand = hands{q};
            
            d = extracted(r).data(q,:); % Get hand data from extract
            l = cell(1,length(d));
            l(:,:) = {datasets(r).label};
            
            data = [data d];
            groups = [groups, l];

            fprintf("Extracted data for dataset: %s, hand: %s and parameter: %s.\n", selectedDataset, selectedHand, selectedParam);
        end
        
        %% Evaluation
        data = data - mean(data,'omitnan'); % Centering
        if (isempty(find(data(~isnan(data)), 1)))
            continue;
        end
        
        [pval,table,stats] = kruskalwallis(data,groups,'off');
        [c,m,h,nms] = multcompare(stats,'ctype','lsd','alpha',0.05);
        
        if pval < 0.05
            if (exist('./results','dir') ~= 7)
                mkdir('./results');
            end
            filename = sprintf('results/%s_%s_.mat', selectedParam, selectedHand);
            figname = sprintf('results/%s_%s_.fig', selectedParam, selectedHand);
            save(filename, 'data','pval','table','stats','c','m','nms');  
            savefig(h,figname,'compact');
            close(h);
        end
    end
    
end
