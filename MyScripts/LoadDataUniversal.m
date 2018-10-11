function [DataStruct] = LoadDataUniversal(params, datapath, prefix)
%{
 Author: Petr Krýže
 Email: petr.kryze@gmail.com
%}

narginchk(3,3) % Checks number of arguments
%% Variables init
DataStruct = struct('id',[],'L1',[],'L2',[],'LS',[],'LC',[],'P1',[],'P2',[],'PS',[],'PC',[]);
%types = {'L1','L2','LS','LC','P1','P2','PS','PC'};
types = {'L1','L2','P1','P2'}; % SELECT MANUALLY!!!

Ntypes = length(types);
defP = properties(PDDataProp); % Available defined properties

%% Loading Loops
for h = 1:Ntypes % Loop through all measurement types
    files = dir(fullfile(datapath,strcat(prefix,types{h},'*.dat')));
    Nfiles = length(files);
    names = cell(Ntypes,Nfiles);
    
    for fid = 1:Nfiles % Loop through all measurements from one type
        % id = measurement source (RBD, BIO, CONTROL) % r = file name
        [id, r] = strtok(files(fid).name,'_');
        n = str2num(r(end-4)); % Measurement number from the file name
        
        k = find(strcmp({DataStruct.id}, id)==1); % k = order in the data struct
        if(isempty(k)) % If the meas. noted by id is not present, expand the struct
            k = length(DataStruct)+1;
        end
        
        DataStruct(k).id = id;
        try
            pd = PDData.Load(fullfile(files(fid).folder,files(fid).name));
            % Second argument is time threshold
            pProp = PDDataProp.InitProperties(pd,22);
        catch ex
            rethrow(ex);
        end

        names{h, fid} = pProp.Data.FileName;
        fprintf("id: %s, type: %s, num: %d\n", id, cell2mat(types(h)), n);
               
        DO = DataStruct(k).(types{h});

        %% Properties selection - stored in DataStruct
        P = [];
        Nparams = length(params);
        for p = 1:Nparams
            if ~isempty(find(strcmp(defP(:),params{p}), 1)) 
                % Parameter exists
                pp = pProp.(params{p});
                if isempty(pp)
                    pp = NaN;
                end
                P(length(P) + 1) = pp;
            end
        end

        DO(size(DO,1) + 1,:) = P;

        DT = setfield(DataStruct(k), types{h}, DO);
        DataStruct(k) = DT;
    end
end

if isempty(DataStruct(1).id)
    DataStruct = DataStruct(2:end);
end

end
