function datasets = getDataObjects(dataroot)
%{
 Author: Petr Krýže
 Email: petr.kryze@gmail.com
-------------------------------------------------------
    Output data structure:
    datasets >> (RBD, BIO, CON)
        entries (dataset,id,fullid,data) >> (patients)
            data (type,number,data) >> (measurements)
                PDData (data object)
%}

%% Path setup
if nargin == 0 % Checks for supplemented path
    root = 'C:\Users\Petr\Disk Google\Thesis\Matlab\Data';
else
    root = dataroot;
end

dObjFilename = 'dataobjects.mat'; % Name of the storage file
% Checks for existence and alternatively loads from file
if exist(fullfile(root,dObjFilename),'file') == 2
    fprintf('Loading from file...\n')
    load(fullfile(root,dObjFilename));
    fprintf('Done!\n')
    return;
end

%% Variables init
paths = {fullfile(root,'RBD'), fullfile(root,'BIO'), fullfile(root,'CON (Control)')};
prefixes = {'RBD*', 'BIO-PD*', 'CON*'};
types = {'L1','L2','LS','LC','P1','P2','PS','PC'};

Nsets = length(paths);
Ntypes = length(types);

msg = '.';
datasets = [];
%% Loading Loops
for p = 1:Nsets
    dataset = [];
    dataObjects = []; % Container for the data objects of the set
    for h = 1:Ntypes % Loop through all measurement types
        files = dir(fullfile(paths{p},strcat(prefixes{p},types{h},'*.dat')));
        Nfiles = length(files);
        
        for fid = 1:Nfiles % Loop through all measurements from one type
            try
                dataObj = PDData.Load(fullfile(files(fid).folder,files(fid).name));
            catch
                warning('File %s could not be loaded.', files(fid).name);
                % pause(); % Pause on failure
                continue
            end
            
            clc % Loading print
            fprintf('%s : Working', files(fid).name)
            if length(msg) <= 3
                msg = strcat(msg,'.');
                fprintf(msg)
            else
                msg = '.';
                fprintf(msg)
            end
            
            dataObjects = [dataObjects; dataObj];
        end
    end
    
    fnames = {dataObjects.FileName}; % Filenames
    ss = split(fnames,'_'); % Split by underscore delimiter
    ids = ss(1,:,1)'; % Patient ids (prefix + number)
    mtypes = ss(1,:,2)'; % Measurement types (hands)
    mnumbers = ss(1,:,3)'; % Measurement numbers
    
    Ndata = length(ids);
    idNums = zeros(Ndata,1); % Just patient ID numbers
    for u = 1:Ndata
        idNums(u) = str2double(ids{u}(length(prefixes{p}):end));
    end
    [idNums,I] = sort(idNums); % Sort by patient ID
    ids = ids(I); % Sort whole ids
    mtypes = mtypes(I); % Sort meas. types
    mnumbers = mnumbers(I); % Sort meas. numbers
    dataObjects = dataObjects(I); % Sort raw data objects
    
    entry = []; % Data for one patient
    entries = []; % Separated patient data
    for i = 1:Ndata
        % Create new patient entry
        if isempty(entry)
            entry.dataset = prefixes{p}(1:end-1); % Save dataset origin
            entry.id = idNums(i); % Numeric ID
            entry.fullid = ids{i}; % dataset name + ID
            measurements = [];
        end
               
        % Add data to the entry
        measurement.type = mtypes{i};
        measurement.number = mnumbers{i};
        measurement.data = dataObjects(i);
        measurement.properties = DataProperties(dataObjects(i));
        measurements = [measurements; measurement];
        
        % 'Save' patient entry
        if (i+1) > Ndata || idNums(i+1) ~= idNums(i)
            entry.measurements = measurements; % Actual patient measurement data
            entries = [entries; entry];
            entry = [];
        end
    end
    
    dataset.id = prefixes{p}(1:end-1);
    dataset.entries = entries;
    
    datasets = [datasets; dataset];
    % datasets > dataset > entries > entry > measurements > measurement >
    % data / properties
end

clc
fprintf('\nLoading Done!\n')

%% Save data objects to a file
fprintf('Saving data objects to %s...\n',dObjFilename)
save(fullfile(root,dObjFilename),'datasets');
fprintf('Saving Done!\n')
end
