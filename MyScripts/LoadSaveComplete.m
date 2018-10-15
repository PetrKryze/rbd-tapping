function [datasets] = LoadSaveComplete(params)
%{
 Author: Petr Krýže
 Email: petr.kryze@gmail.com
%}
%% Load Data and save
if nargin == 0 % Default selection
    params = {'AmpAvg','VelOAvg','AmpAvgMax','VelCAvg','FrqAvg'};
elseif nargin > 1 || isempty(params)
    return;
end
root = 'C:\Users\Petr\Disk Google\Thesis\Matlab';
dfolder = 'Data';
paths{1} = fullfile(root,dfolder,'RBD');
paths{2} = fullfile(root,dfolder,'BIO');
paths{3} = fullfile(root,dfolder,'CON (Control)');

prefixes = {'RBD*', 'BIO-PD*', 'CON*'};
labels = {'RBD','BIO','CON'};

fprintf("Loading and evaluating data.\n");
tic
Nsets = length(labels);
d = cell(1,Nsets);
paramSets = cell(1, Nsets);
for i = 1:Nsets
    d{i} = LoadDataUniversal(params, paths{i}, prefixes{i});
    paramSets{i} = params; % Option for different parameters from each set
end
datasets = struct('label',labels,'data',d,'param',paramSets);
toc

filename = fullfile(root,dfolder,'datasets.mat');
save(filename, 'datasets');
% load train % NOT WORKING
% sound(y,Fs)
fprintf("Complete data sets for parameters %s loaded and saved to %s.\n", getParamStr(params), filename);
return;

%%
    function str = getParamStr(params)
        str = "";
        for j = 1:length(params)
            str = strcat(str,params{j},", ");
        end
    end

end
