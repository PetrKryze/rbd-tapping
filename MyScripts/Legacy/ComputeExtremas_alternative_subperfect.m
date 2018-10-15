%% Compute Extremes
function [MinVal, MaxVal] = ComputeExtremas(DataDist,window)
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

mData = mData - mean(mData); % Centering of smoothed data

MaxVal = [];
MinVal = [];
% Find zero crossings
ix = 1;
flag = 0;
for j = 2:Ndata
    if mData(j - 1) < 0
        if mData(j) >= mData(j - 1)
            if mData(j) >= 0
                ix = [ix j];
                flag = 1;
            end
        end
    else % mData(j - 1) >= 0
        if mData(j) <= mData(j - 1)
            if mData(j) <= 0
                ix = [ix j];
                flag = 1;
            end
        end
    end
    
    if flag == 1
        frame = mData(ix(end-1):ix(end));
        if mean(frame) >= 0
            [mx, mxix] = max(DataDist(ix(end-1):ix(end)));
            MaxVal = [MaxVal; [ix(end-1) + mxix - 1, mx]];
        else
            [mn, mnix] = min(DataDist(ix(end-1):ix(end)));
            MinVal = [MinVal; [ix(end-1) + mnix - 1, mn]];
        end
        flag = 0;
    end
end

[MaxVal, MinVal] = PDData.addMissingExtremes(DataDist,mData,MaxVal,MinVal);

close all
figure
plot(DataDist)
set(gcf,'Position',[20 60 800 750])
hold on
grid on
scatter(MinVal(:,1),MinVal(:,2), 'm','o')
scatter(MaxVal(:,1),MaxVal(:,2), 'm','x')
scatter(1:1:Ndata,DataDist, 'r','.')
close
end

%% Add Missing Extremes
function [MaxVal, MinVal] = addMissingExtremes(DataDist,mData,MaxVal,MinVal)
Ndata = length(DataDist);
k = 1;
p = 1;
MaxVal2 = [];
MinVal2 = [];
while(1)
    if k > size(MaxVal,1) || p > size(MinVal,1)
        break;
    end
    if MaxVal(k,1) < MinVal(p,1)
        ix1 = MaxVal(k,1);
        ix2 = MinVal(p,1);
        k = k + 1;
    else
        ix1 = MinVal(p,1);
        ix2 = MaxVal(k,1);
        p = p + 1;
    end
    
    d = diff(mData(ix1:ix2));
    ixd = find(abs(d) < 0.006);
    ixd = ixd + ix1 - 1;
    
    for m = 1:length(ixd)
        if ixd(m) < 2
            ixd1 = 1;
            ixd2 = 3;
        elseif ixd(m) > Ndata - 1
            ixd1 = Ndata - 2;
            ixd2 = Ndata;
        else
            ixd1 = ixd(m) - 1;
            ixd2 = ixd(m) + 1;
        end
        
        if DataDist(ixd(m)) >= mean(DataDist(ixd1:ixd2))
            [mx, mxix] = max(DataDist(ixd1:ixd2));
            MaxVal2 = [MaxVal2; [ixd1 + mxix - 1, mx]];
        else
            [mn, mnix] = min(DataDist(ixd1:ixd2));
            MinVal2 = [MinVal2; [ixd1 + mnix - 1, mn]];
        end
    end
    
end

for h = 1:length(MaxVal2)
    if isempty(find(abs(MaxVal(:,1) - MaxVal2(h,1)) < 5, 1)) && isempty(find(abs(MinVal(:,1) - MaxVal2(h,1)) < 5, 1))
        MaxVal = [MaxVal; MaxVal2(h,:)];
    end
end

for h = 1:length(MinVal2)
    if isempty(find(abs(MinVal(:,1) - MinVal2(h,1)) < 5, 1)) && isempty(find(abs(MaxVal(:,1) - MinVal2(h,1)) < 5, 1))
        MinVal = [MinVal; MinVal2(h,:)];
    end
end

end