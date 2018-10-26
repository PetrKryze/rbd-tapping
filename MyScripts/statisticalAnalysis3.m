%% Statistic analysis 3
%{
 Author: Petr Krýže
 Email: petr.kryze@gmail.com
    Performs statistical analysis in the means of ranksum test on tapping
    test data from RBD affected patients and a control group. It takes all 
    left hand measurements, calculates various parameters and then averages
    them. Same procedure is applied to right hand measurements. Output of
    the property extraction is then larger and smaller value of this pair
    of averaged measurements, representing, in a sense, more and less
    affected part of the patient's body.
%}

%% Init and prep
clc
clear
close all

% Settings
overwritechk = 0; % Set to 1 to enable file overwrite prompt
TimeCut = 23; % Crop value for maximum record time
root = 'C:\Users\Petr\Disk Google\Thesis\Matlab\Results';
%testType = TestType.Normal;
%testType = TestType.Shaking; % Type of measurement to test
testType = TestType.Normal;

datasets = getDataObjects();

props = properties('DataProperties');
Nprops = length(props);
proplabels = cell(1,Nprops*2);
for p = 1:Nprops
    proplabels((p*2) - 1) = {sprintf('%s_max', props{p})};
    proplabels(p*2) = {sprintf('%s_min', props{p})};
end

data = [];
groups = {};

%% Property extraction
fprintf('Extracting properties...\n')
Nsets = length(datasets);
for i = 1:Nsets
    Nentries = length(datasets(i).entries);
    
    rowlabels = cell(Nentries,1);
    rowlabels(:,:) = {datasets(i).id};
    
    rows = zeros(Nentries,Nprops*2);
    for j = 1:Nentries
        meas = datasets(i).entries(j).measurements;
        
        % Structs with measurement data
        Lmeas = meas(startsWith({meas.type},testType.getTypeLabels('left')));
        Rmeas = meas(startsWith({meas.type},testType.getTypeLabels('right')));
        
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
fprintf('Done!\n')

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
    
    if h % Null hypothesis rejected
        prop = proplabels{n};
        foldername = 'results_ranksum_sa3';
        if (exist(fullfile(root, foldername),'dir') ~= 7)
            mkdir(fullfile(root, foldername));
        end
        filename = sprintf('%s_%s.mat', prop, char(testType));
        filepath = fullfile(root,foldername,filename);
        ch = 1;
        if (exist(filepath,'file') ~= 0 && overwritechk == 1)
            if overwriteDialog(filename)
                ch = 1;
            else
                ch = 0;
            end
        end
        
        if ch
            fprintf('SUCCESS: %s_%s | Saving to %s ...\n', prop, char(testType), foldername)
            save(filepath, 'rbdData', 'conData', 'data','stats','pval','groups');
        end
        
        %% Kruskalwallis test
        [pval,table,stats] = kruskalwallis(data(:,n),groups,'off');
        [c,m,h,nms] = multcompare(stats,'ctype','lsd','alpha',0.05);
        
        if pval < 0.05
            if (exist(fullfile(root, 'results'),'dir') ~= 7)
                mkdir(fullfile(root, 'results'));
            end
            subfolder = 'kruskalwallis';
            if (exist(fullfile(root, foldername, subfolder),'dir') ~= 7)
                mkdir(fullfile(root, foldername, subfolder));
            end
            
            filename = sprintf('KW_%s_%s.mat', prop, char(testType));            
            filepath = fullfile(root,foldername,subfolder,filename);            
            figname = sprintf('KW_%s_%s.fig', prop, char(testType));
            figpath = fullfile(root,foldername,subfolder,figname);
            
            save(filepath, 'data','pval','table','stats','c','m','nms');
            savefig(h,figpath,'compact');
            close(h);
        end
    end
    
end
fprintf('Done!\n')

function m = getPropertyMean(struct,propname,cut)
val = NaN(length(struct),1);
for k = 1:length(struct)
    struct(k).properties.TimeCut = cut;
    val(k) = struct(k).properties.(propname);
end
m = mean(val,'omitnan');
end
