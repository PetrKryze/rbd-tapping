function [labels, dataOut] = selectHandData(data, hand)
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
Nfiles = length(data);
labels = cell(1,Nfiles);
dataOut = zeros(1,Nfiles);

types = {'L1','L2','LS','LC','P1','P2','PS','PC'};
if isempty(find(strcmp(types,hand), 1))
    fprintf("Wrong hand type format!")
    return
end

handIdx = find(strcmp(types, hand));

for i = 1:Nfiles
    
    if isnan(data(handIdx,i))
        labels(i) = {"NaN"};
        dataOut(i) = NaN;
        continue;
    else
        labels(i) = {hand};
        dataOut(i) = data(handIdx,i);
    end

end

end