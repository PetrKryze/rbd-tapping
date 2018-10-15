clc
clear
close all
figure

load('C:\Users\Petr\Disk Google\Thesis\Matlab\results_ranksum_sa2\FrqReg_WorseHand_.mat')
x1 = data(find(strcmp(groups,'RBD') == 1));
x2 = data(find(strcmp(groups,'CON') == 1));

load('C:\Users\Petr\Disk Google\Thesis\Matlab\results_ranksum_sa2\OTDec_WorseHand_.mat')
y1 = data(find(strcmp(groups,'RBD') == 1));
y2 = data(find(strcmp(groups,'CON') == 1));

hold on
scatter(x1,y1,'blue','filled')
scatter(mean(x1,'omitnan'),mean(y1,'omitnan'),'blue','x')

grid on
scatter(x2,y2,'red','filled')
scatter(mean(x2,'omitnan'),mean(y2,'omitnan'),'red','x')
xlabel('FrqReg on Worse Hand')
ylabel('OTDec on Worse Hand')

title('Statistical analysis 2 - ranksum detected properties values')
hold off