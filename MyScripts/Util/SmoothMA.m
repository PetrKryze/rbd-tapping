function [mData, minData] = SmoothMA(DataDist,window)
%% Smooth out data using moving average window
DataDist = DataDist';
Ndata = length(DataDist);

if length(window) == 1
    window = ones(1,window);
end

Nwin = length(window); % Size of the window
if Nwin >= Ndata % Length control
    error("Window is too large!");
    return;
end
Nwinhalf = floor(Nwin/2); % Half of the window
even = 1 - mod(Nwin,2); % Even window length modifier

mData = zeros(1,Ndata); % Allocation of mean data vector
minData = zeros(1,Ndata);
for i = 1:Ndata
    if i < Nwinhalf + 1 % Beginning
        dframe = DataDist(1:Nwinhalf + i - even);
        wframe = window(Nwinhalf - i + 2 : end);
    elseif i > Ndata - Nwinhalf + even % End
        dframe = DataDist(i - Nwinhalf : Ndata);
        wframe = window(1 : end-Nwinhalf+Ndata-i+even);
    else % Middle (full window)
        dframe = DataDist(i - Nwinhalf : i + Nwinhalf - even);
        wframe = window;
    end
    mData(i) = mean(dframe.*wframe);
    minData(i) = min(dframe.*wframe);
end

end