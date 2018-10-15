clc
clear
close all

load('easy_data.mat')

Ndata = length(DataDist);
Nrange = 100; % Number of values to calculate the prominence threshold from
widthThrCoef = 0.2; % Modifies the threshold for peak width

mData = DataDist - mean(DataDist);
posN = floor(Nrange*(length(mData(mData > 0))/Ndata));
negN = floor(Nrange*(length(mData(mData < 0))/Ndata));

s = sort(DataDist,'descend');
promThr = mean(s(1:posN)) - mean(s(end-negN-1:end));
promThr = promThr * 0.15; % Prominence value threshold

% Find maximum peaks
[maxv, maxix, width, prom] = findpeaks(DataDist,'MinPeakDistance',10,'MinPeakProminence',promThr);
badwidth = find(width < mean(width)*widthThrCoef);

maxs = [maxix, maxv];
maxs(badwidth,:) = [];

% Find minimums in between the maximums
mins = zeros(length(maxs) - 1,2);
for i = 1:length(maxs) - 1
    frame = DataDist(maxs(i,1):maxs(i+1,1));

    [minv, minix] = min(frame);
    mins(i,:) = [maxs(i,1) + minix, minv];
end

% Add first extreme
if maxs(1,1) < mins(1,1) % First found extreme is a maximum
    [minv_0, minix_0] = min(DataDist(1:maxs(1,1)));
    mins = [[minix_0, minv_0] ; mins];
else % First found extreme is a minimum
    [maxv_0, maxix_0] = max(DataDist(1:mins(1,1)));
    maxs = [[maxix_0, maxv_0] ; maxs];
end

% Add last extreme
if maxs(end,1) > mins(end,1) % Last found extreme is a maximum
    [minv_end, minix_end] = min(DataDist(maxs(end,1):end));
    mins = [mins; [maxs(end,1) + minix_end, minv_end]];
else % Last found extreme is a minimum
    [maxv_end, maxix_end] = max(DataDist(mins(end,1):end));
    maxs = [maxs; [mins(end,1) + maxix_end, maxv_end]];
end

%% Plotting
figure
plot(DataDist)
hold on
grid on
scatter(maxs(:,1), maxs(:,2), 'm', 'o')
scatter(mins(:,1), mins(:,2), 'r', 'o')

%line([1,Ndata],[m,m],'Color','black');

% line([1,Ndata],[posMV,posMV],'Color','black');
% line([1,Ndata],[negMV,negMV],'Color','black');

hold off

