function [output] = extractSingleProperty(datasets, paramIdx)
%% Author: Petr Krıe
%% Email: petr.kryze@gmail.com
%%
Nsets = length({datasets.label});
%types = {'L1','L2','LS','LC','P1','P2','PS','PC'};
types = {'L1','L2','P1','P2'};
Ntypes = length(types);

%%
for i = 1:Nsets
    Ndata = length(datasets(i).data);
    xdata = NaN(2,Ndata);

    for j = 1:Ndata
        a = [];
        
        dlens = NaN(1,4);
        for k = 1:Ntypes
            dlens(k) = size(datasets(i).data(j).(types{k}),1);
        end        
        
        for k = 1:Ntypes
            if isempty(a)
                a = NaN(max(dlens), Ntypes);
            end
            P = datasets(i).data(j).(types{k});
            
            for p = 1:size(P,1)
                a(p,k) = P(p,paramIdx);
            end
        end
        
        % Calculating mean value from one hand over all measurements
        if sum(~isnan(a)) > 0
            mL = mean(mean(a(:,1:2), 1, 'omitnan'), 'omitnan');
            mP = mean(mean(a(:,3:4), 1, 'omitnan'), 'omitnan');            

            xdata(:,j) = [mL ; mP];
        end
    end

    output(i).handlabels = {'Lmean'; 'Pmean'};
    output(i).data = xdata;
end

end