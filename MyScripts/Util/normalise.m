function dataout = normalise(data)
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
a = length(find(~isnan(data(1,:))));
b = length(find(~isnan(data(2,:))));

newdata = zeros(2,min(a,b));
k = 1;
Ndata = length(data);
for j = 1:Ndata % Skip all NaN data
    if ~isnan(data(1,j)) && ~isnan(data(2,j))
        newdata(:,k) = [data(1,j) ; data(2,j)];
        k = k+1;
    end
end

%stdd = std(data);
%data = (data - mean(data))/ stdd; % Centering

Ndata = length(newdata);
minDx = min(newdata(1,:));
maxDx = max(newdata(1,:));
minDy = min(newdata(2,:));
maxDy = max(newdata(2,:));

dataout = zeros(2,Ndata);
for i = 1:Ndata
    % Feature Scaling    
    dataout(1,i) = (newdata(1,i) - minDx) / (maxDx - minDx);
    dataout(2,i) = (newdata(2,i) - minDy) / (maxDy - minDy);
end

end