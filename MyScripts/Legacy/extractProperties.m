%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%% Cleanup
clc
clear
close all
%%
% LoadSaveComplete;
load('datasets.mat')
Nsets = length({datasets.label});
types = {'L1','L2','LS','LC','P1','P2','PS','PC'};

%% SETTINGS - Change Here
pix = [3 4]; % Selected 2 parameters for extraction from datasets
selectedHand = 'L2';

%% Extraction
tic
for i = 1:Nsets  
    xdata = [];
    ydata = [];
    idsA = {};
    idsB = {};
    fprintf('Extracting %s, %s from data set %s\n', datasets(i).param{pix}, datasets(i).label)

    for j = 1:length(datasets(i).data) 
        a = [];
        b = [];
        for k = 1:length(types)
            P = getfield(datasets(i).data(j),types{k}); 
            
            if ~isempty(P)
                param1 = P(:,pix(1))';
                param2 = P(:,pix(2))';
                if size(param1,2) < size(a,2)
                    param1 = [param1 NaN(1, size(a,2) - size(param1,2))];
                elseif size(param1,2) > size(a,2)
                    a = [a NaN(size(a,1),1)];  
                end
                
                if size(param2,2) < size(b,2)
                    param2 = [param2 NaN(1, size(b,2) - size(param2,2))];
                elseif size(param2,2) > size(b,2)
                    b = [b NaN(size(b,1),1)];  
                end
            else
                param1 = NaN(1,size(b,2));
                param2 = NaN(1,size(b,2));
            end          
            a = [a ; param1];
            b = [b ; param2];
        end
        
        for nn = 1:size(a,2)
           idsA = [idsA datasets(i).data(j).id]; 
        end
        
        for nn = 1:size(b,2)
           idsB = [idsB datasets(i).data(j).id]; 
        end
        xdata = [xdata a];
        ydata = [ydata b];
    end
    
    [handlabels, ydata] = selectHandData(ydata, selectedHand);    
    %[handlabels, ydata] = getMaxOfMinHand(ydata);
    matchYDataAndSave(handlabels, ydata, xdata, datasets(i).label, datasets(i).param);
end
toc
fprintf('Data extracted!\n')