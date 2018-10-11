%clear
%addpath 'd:\\mprgs\\!Sync\\BradykAn\\MTools\\Libs\\';
%DataPath =  'd:\\mprgs\\_Data\\RBD\RBDDataP\\';
addpath 'C:\Users\Petr\Desktop\Diplomka\RBDTapping\Skripty\Libs';
DataPath =  'C:\Users\Petr\Desktop\Diplomka\RBDTapping\Skripty\RBDprocess';

BD = load('bio1.mat');
BD = BD.D;
KD = load('kon.mat');
KD = KD.D;
RD = load('rbd1.mat');
RD = RD.D;

%%
% [ m,dev,s ] = glmfit(D(:,sl),D(:,end),'binomial');  

V = {'L1','L2','P1','P2','LS','LC','PS','PC'};
P = {'FrqAvg','FrqStd','AmpDec','VelO','VelC'};
for k = 1:length(V)
    subplot(2,4,k)
    RV = cat(1,RD.(V{k}));
    KV = cat(1,KD.(V{k}));
    BV = cat(1,BD.(V{k}));
    RV(:,4) = RV(:,4)/100;
    KV(:,4) = KV(:,4)/100;
    BV(:,4) = BV(:,4)/100;
    
    RL = glmval(m,RV(RV(:,4)<0.70,[3,4]),'identity');  
    KL = glmval(m,KV(KV(:,4)<0.70,[3,4]),'identity');  
    BL = glmval(m,BV(BV(:,4)<0.70,[3,4]),'identity');  
    %UnivarScatterMedian(padcat(KV(KV(:,4)<0.70,4),RV(RV(:,4)<0.70,4),BV(BV(:,4)<0.70,4)),'Label',{'KON','RBD','PD'},'MarkerFaceColor',[0 0 0],'Whiskers','box');
    %UnivarScatterMedian(padcat(KV(:,3),RV(:,3),BV(:,3)),'Label',{'KON','RBD','PD'},'MarkerFaceColor',[0 0 0],'Whiskers','box');
    UnivarScatterMedian(padcat(KL,RL,BL),'Label',{'KON','RBD','PD'},'MarkerFaceColor',[0 0 0],'Whiskers','box');
    title(V{k})
end
