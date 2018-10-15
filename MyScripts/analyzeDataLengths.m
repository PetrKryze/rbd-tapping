function [thrLen95, perc, minLen] = analyzeDataLengths()
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
close all
d = getDataObjects();
Nsets = length(d);

dur = [];
for q = 1:Nsets
    Nid = length(d(q).entries);
    
    for o = 1:Nid
        Nmeas = length(d(q).entries(o).measurements);
        
        for p = 1:Nmeas
            dur = [dur; d(q).entries(o).measurements(p).data.DataTime(end)];
        end
    end
end
minLen = min(dur);
fprintf('Shortest data record: %.2f seconds.\n',minLen)

[N, EDGES] = histcounts(dur,'BinWidth',1);

sums = zeros(length(N),2);
flag = 0;
thrLen95 = 0;
for b = 1:length(N)
    bn = EDGES(b + 1);
    sm = (sum(N(1:b))/length(dur))*100;
    if sm >= 95 && flag == 0
        fprintf('%.2f percent of data in times up to %d seconds.\n',sm,bn)
        thrLen95 = bn;
        perc = sm;
        flag = 1;
    end
    sums(b,:) = [bn, sm];
end

figure(1)
plot(sums(:,1),sums(:,2))
grid on
hold on
line([min(sums(:,1)),max(sums(:,1))],[95,95],'LineStyle',':','Color','black','LineWidth',2)
line([thrLen95,thrLen95],[0,100],'LineStyle',':','Color','red','LineWidth',2)
xlim([min(sums(:,1)),max(sums(:,1))])
legend('% of data in sumation','95% Percent Threshold','Location','southeast')
xlabel('Data time length [s]')
ylabel('Percentage [%]')
title('Data length Analysis')
hold off

figure(2)
histogram(dur)
grid on
title('Data length Histogram')
xlabel('Data time length [s]')
ylabel('Counts [-]')

end