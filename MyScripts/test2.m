close all
clear

d = getDataObjects();

id = 1;
figure('Name',sprintf('Data %s', d(id).fullid))
Ndata = length(d(id).data);
for m = 1:Ndata
    subplot(ceil(Ndata/2),2,m)
    plot(d(id).data(m).data.DataTime, d(id).data(m).data.DataDist)
    title(sprintf('%s - %s', d(id).data(m).type, d(id).data(m).number))
    grid on
end
