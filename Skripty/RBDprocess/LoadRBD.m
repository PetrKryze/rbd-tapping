clc
clear
close all
DataPath =  'C:\Users\Petr\Desktop\Diplomka\RBDTapping\SelectedData';

D = struct('id',[],'L1',[],'L2',[],'LS',[],'LC',[],'P1',[],'P2',[],'PS',[],'PC',[]);
M = containers.Map;
types = {'L1','L2','LS','LC','P1','P2','PS','PC'};
P = {'FrqAvg','FrqStd','AmpDec','VelO','VelC'};

adata = zeros(1,length(types));
fdata = zeros(1,length(types));

for h = 1:length(types) % Pres vsechny druhy mereni
    
    files = dir(fullfile(DataPath,strcat('RBD*',types{h},'*.dat')));
    names = [];
    for fid = 1:length(files) % Pres vsechny zaznamy od jednoho druhu mereni
        % id = druh mìøení (RBD, BIO, CONTROL)
        % r = název souboru
        [id r] = strtok(files(fid).name,'_');
        n = str2num(r(end-4)); % Èíslo mìøení z názvu souboru
        
        k = find(strcmp({D.id}, id)==1); % k = poøadí v souboru s daty
        if(isempty(k))
            k = length(D)+1;
        end
        
        D(k).id = id;
        try
            pd = PDData.Load(fullfile(files(fid).folder,files(fid).name));
            pProp = PDDataProp.InitProperties(pd,15);
        catch
            continue
        end
        %         if(n~=1) %% Skips other than 1st measurements
        %             continue
        %         end
        names{h, fid} = pProp.Data.FileName;
        %D(k).(V{1})(n) = pProp;
        DO = getfield(D(k), types{h});
        
        fprintf("id: %s, type: %s, num: %d\n", id, cell2mat(types(h)), n);
        adata(h,fid) = pProp.AmpAvg;
        fdata(h,fid) = getMaxFreq(names(h, fid), pd);
        
        %% SPECIFIKACE PARAMETRU KTERY ME ZAJIMAJI - NAHRAJI SE DO MATICE V MATLABU
        DO(n,:) =[pProp.FrqAvg,pProp.FrqStd,pProp.AmpDec,pProp.VelON,pProp.VelCN];
        DT = setfield(D(k), types{h},DO);
        D(k) = DT;
    end
end

%% My Scripts
[labels, fdataWorse] = processWorseFreq(fdata, length(files))
processAvgAmp_WorseFreq(labels, fdataWorse, adata, length(files))



%%
save('rbd1','D')