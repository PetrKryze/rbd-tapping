%% Statistic analysis 3
%{
 Author: Petr Krýže
 Email: petr.kryze@gmail.com
%}

%% Init and prep
clc
clear
close all

TimeCut = 22;
root = 'C:\Users\Petr\Disk Google\Thesis\Matlab\Results';
datasets = getDataObjects();

props = properties(DataProperties);
Nprops = length(props);
proplabels = cell(1,Nprops*2);
for p = 1:Nprops
    proplabels((p*2) - 1) = {sprintf('%s_max', props{p})};
    proplabels(p*2) = {sprintf('%s_min', props{p})};
end

data = [];
groups = {};

%% Property extraction
Nsets = length(datasets);
for i = 1:Nsets
    Nentries = length(datasets(i).entries);
    
    rowlabels = cell(Nentries,1);
    rowlabels(:,:) = {datasets(i).id};
    
    rows = zeros(Nentries,Nprops*2);
    for j = 1:Nentries
        meas = datasets(i).entries(j).measurements;
        
        % Structs with measurement data
        Lmeas = meas(startsWith({meas.type},'L'));
        Rmeas = meas(startsWith({meas.type},'P'));
        
        row = zeros(1,Nprops*2);
        for k = 1:Nprops
            Lmean = getPropertyMean(Lmeas,props{k},TimeCut);
            Rmean = getPropertyMean(Rmeas,props{k},TimeCut);
            
            % Maximum and minimum of average of measurements
            % (Take data from all measurements on one hand, average it,
            % compare it with the average over all measurements on the
            % other hand, save larger and smaller value)
            row((k*2) - 1) = max([Lmean, Rmean]);
            row(k*2) = min([Lmean, Rmean]);
        end
        
        rows(j,:) = row;
    end
    
    data = [data; rows];
    groups = [groups; rowlabels];
end


%% Evaluation
fprintf('Analyzing the datasets...\n')
for n = 1:Nprops*2 % Loop through all calculated properties
    % data = data - mean(data,'omitnan'); % Centering
    if (isempty(find(data(~isnan(data)), 1)))
        continue;
    end
    
    rbdData = data(find(strcmp(groups,'RBD') == 1),n);
    conData = data(find(strcmp(groups,'CON') == 1),n);
    
    %% Ranksum test
    [pval,h,stats] = ranksum(rbdData,conData);
    
    if h
        prop = proplabels{n};
        foldername = 'results_ranksum_sa3';
        if (exist(fullfile(root, foldername),'dir') ~= 7)
            mkdir(fullfile(root, foldername));
        end
        filename = sprintf('%s.mat', prop);
        fprintf('SUCCESS: %s | Saving to %s ...\n', prop, foldername)
        save(fullfile(root,foldername,filename), 'rbdData', 'conData','stats','pval','groups');
    end
    
    %% Kruskalwallis test
%     [pval,table,stats] = kruskalwallis(data(:,n),groups,'off');
%     [c,m,h,nms] = multcompare(stats,'ctype','lsd','alpha',0.05);
%     
%     if pval < 0.05
%         if (exist(fullfile(root, 'results'),'dir') ~= 7)
%             mkdir(fullfile(root, 'results'));
%         end
%         filename = fullfile(root, 'results', sprintf('%s_.mat', proplabels{n}));
%         figname = fullfile(root, 'results', sprintf('%s_.fig', proplabels{n}));
%         save(filename, 'data','pval','table','stats','c','m','nms');
%         savefig(h,figname,'compact');
%         close(h);
%     end
end
fprintf('Done!\n')

function m = getPropertyMean(struct,propname,cut)
val = NaN(length(struct),1);
for k = 1:length(struct)
    struct(k).properties.SampleCut = cut;
    val(k) = struct(k).properties.(propname);
end
m = mean(val,'omitnan');
end



