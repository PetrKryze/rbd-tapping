classdef PDDataProp < hgsetget
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    properties(SetAccess = private)
        allProps;
    end
    
    properties(SetAccess = public)
        Data
        AmpAvg
        AmpAvgMin
        AmpAvgMax
        AmpAvg15
        AmpAvg35
        AmpK
        Amp3D1
        Amp10
        AmpStd
        AmpMean
        AmpMD1
        AmpMDM
        AmpDec
        OT
        OTDec
        FrqAvg
        FrqAvg15
        FrqAvg35
        FrqStd
        Frq3D1
        Frq10
        FrqReg
        %FTDec
        TapTime
        Rythm
        NumOfOpen
        VelO4
        VelC4
        VelOAvg
        VelOStd
        VelCStd
        VelCAvg
        VelOAvg15
        VelCAvg15
        VelOAvg35
        VelCAvg35
        VelOAvgMax
        VelCAvgMax
        VelO3D1
        VelC3D1
        Vel10OAvg
        Vel10CAvg
        Vel10O3D1
        Vel10C3D1
        VelON
        VelCN
        VMax
        VMin
        Time
    end
    
    %get properties
    methods
        function value = get.VelOAvg(obj)
            value = median(obj.VMax(obj.Data.DataTime(obj.VMax(:,1)) < obj.Time,2));
        end
        
        function value = get.VelCN(obj)
            value = obj.VelCAvg / max(medfilt1(obj.Data.MaxV(obj.Data.MaxT < obj.Time ,2),3));
        end
        
        function value = get.VelON(obj)
            VMAX  = cat(2,obj.VMax, ones(size(obj.VMax,1),1));
            AMAX  = cat(2,obj.Data.MaxV, 2*ones(size(obj.Data.MaxV,1),1));
            VMAX = VMAX(obj.Data.MaxT < obj.Time ,:);
            AMAX = AMAX(obj.Data.MaxT < obj.Time ,:);
            ALMAX = sortrows(cat(1,AMAX,VMAX));
            OUT = [];
            for k=2:size(ALMAX,1)-1
                if(ALMAX(k,3) == 1 && ALMAX(k+1,3) == 2 && ALMAX(k-1,3) == 2 )
                    OUT = [OUT,ALMAX(k,2) * (-obj.Data.DataTime(ALMAX(k-1,1)) + obj.Data.DataTime(ALMAX(k+1,1)))];
                end
            end
            
            %value = obj.VelOAvg / max(medfilt1(obj.Data.MaxV(obj.Data.MaxT < obj.Time ,2),3));
            %q = quantile(OUT,[0.25 0.75]);
            value = median(OUT);
        end
        
        function value = get.VelOStd(obj)
            %value = std(obj.VMax(obj.Data.DataTime(obj.VMax(:,1)) < obj.Time,2));
            v = quantile(obj.VMax(obj.Data.DataTime(obj.VMax(:,1)) < obj.Time,2),[0.25 0.75]);
            value = (v(2) - v(1))/2;
        end
        
        function value = get.VelCAvg(obj)
            value = median(obj.VMin(obj.Data.DataTime(obj.VMin(:,1)) < obj.Time,2));
            %value = mean(obj.VMin(obj.VMin(:,2)~=-inf,2));
        end
        
        function value = get.VelCStd(obj)
            v = quantile(obj.VMin(obj.Data.DataTime(obj.VMin(:,1)) < obj.Time,2),[0.25 0.75]);
            value = (v(2) - v(1))/2;
        end
        
        function value = get.AmpAvg(obj)
            value = mean(obj.Data.MaxV(:,2));
        end
        
        function value = get.AmpAvg15(obj)
            mask = obj.Data.MaxT <= 5;
            value = mean(obj.Data.MaxV(mask,2));
        end
        
        function value = get.AmpStd(obj)
            dt = obj.Data.MaxV(obj.Data.MaxT < obj.Time ,2)/max(medfilt1(obj.Data.MaxV(obj.Data.MaxT < obj.Time ,2),3));
            value = std(dt);
        end
        
        function value = get.AmpMean(obj)
            dt = obj.Data.MaxV(obj.Data.MaxT < obj.Time ,2)/max(medfilt1(obj.Data.MaxV(obj.Data.MaxT < obj.Time ,2),3));
            value = mean(dt);
        end
        
        function value = get.Amp10(obj)
            
            dt = medfilt1(obj.Data.MaxV(1:end,2),3);
            if (length(dt) < 10)
                dt = dt(1:end);
            else
                dt = dt(1:10);
            end
            if(length(dt) > 5)
                mxVal = max(dt(1:5));
                value = 1-min(dt(6:end))/mxVal;
            else
                value = 1-min(dt)/max(dt);
            end
        end
        
        function value = get.VelO4(obj)
            mask = obj.Data.DataTime(obj.VMax(:,1)) >= obj.Data.DataTime(end)-4;
            value = mean(obj.VMax(mask,2));
        end
        
        function value = get.VelC4(obj)
            mask = obj.Data.DataTime(obj.VMin(:,1)) >= obj.Data.DataTime(end)-4;
            value = mean(obj.VMin(mask,2));
        end
        
        function value = get.VelOAvg15(obj)
            mask = obj.Data.DataTime(obj.VMax(:,1)) <= 5;
            value = mean(obj.VMax(mask,2));
        end
        
        function value = get.OT(obj)
            V = cat(2,obj.VMax,zeros(size(obj.VMax,1),1));
            AX = cat(2,obj.Data.MaxV,zeros(size(obj.Data.MaxV,1),1));
            AM = cat(2,obj.Data.MinV,zeros(size(obj.Data.MinV,1),1));
            AE = diff(obj.Data.ExV);
            AE(AE(:,3) == 1,:,:);
            M = [false;AE(:,3) == 1];
            AVE = cat(2,obj.Data.ExV(M,1),AE(AE(:,3) == 1,2:3));
            
            VA = sortrows(cat(1,V,AVE));
            value =[];
            id = 1;
            for k = 3:size(VA,1)
                if(VA(k,3) == 1 && VA(k-1,3) == 0)
                    value(id,1) = VA(k,1);
                    value(id,2) = VA(k,2) +0.1* VA(k-1,2);
                    id = id +1;
                end
            end
            
        end
        
        function value = get.OTDec(obj)
            OTdata = obj.OT;
            if (isempty(OTdata))
                value = NaN;
            else
                OTTime = obj.Data.DataTime(OTdata(:,1));
                mask = OTTime < obj.Time ;
                
                dt = medfilt1(OTdata(:,2),3);
                dt = dt(mask);
                if(length(dt) >5)
                    mxVal = max(dt(1:5));
                    value = 1-min(dt(6:end))/mxVal;
                else
                    value = 1-mean(dt)/max(dt);
                end
            end
        end
        
        function value = get.AmpDec(obj)
            mask = obj.Data.MaxT < obj.Time ;
            dt = medfilt1(obj.Data.MaxV(:,2),3);
            dt = dt(mask);
            if(length(dt) >5)
                mxVal = max(dt(1:5));
                value = 1-min(dt(6:end))/mxVal;
            else
                value = 1-mean(dt)/max(dt);
                
            end
        end
        
        function value = get.TapTime(obj)
            fs = obj.Data.Freq;
            fc =8;
            [b,a] = butter(6,fc/(fs/2));
            data =  obj.Data.DataDist;
            datatime = obj.Data.DataTime;
            data = data(datatime < obj.Time);
            datatime = datatime(datatime < obj.Time);
            if(sum(diff(datatime) == 0) > 0)
                m = [true ;diff(datatime) ~= 0];
                data = data(m);
                datatime = datatime(m);
                warning(strcat(obj.Data.FileName,' has 0 time diff'))
            end
            data = interp1(datatime,data,0:1/fs:datatime(end));
            datatime = 0:1/fs:datatime(end);
            
            vm= [obj.VMin,zeros(size(obj.VMin,1),1)];
            vx= [obj.VMax,ones(size(obj.VMax,1),1)];
            vc = sortrows([vm;vx]);
            vt = obj.Data.DataTime(vc(:,1));
            mnomove = [0,abs(diff(data)*fs) <10];
            casik = [];
            
            %subplot(2,1,1)
            %plot(datatime,data,'b')
            %hold on
            for k =2:size(vc,1)
                if(vt(k) > obj.Time)
                    break;
                end
                if(vc(k-1,3)== 0 && vc(k,3)==1)
                    t1 = vt(k-1);
                    t2 = vt(k);
                    m = datatime > t1 & datatime < t2;
                    casik = [casik,sum(mnomove&m) /fs];
                    %     plot(datatime(mnomove & m),data(mnomove &m ),'r*');
                end
                
            end
            %hold off
            
            %subplot(2,1,2)
            %plot(diff(data)*fs,'r*')
            value = median(casik);
        end
        %{
function value = get.FTDec(obj)
            fr = 1/240;
            mxT = obj.Data.MaxT(2:end-1);
            %mxT = mxT(mxT < obj.Time);
            mnT = obj.Data.MinT;%obj.Data.MinT(obj.Data.MinT<obj.Time);
            P = cat(2,[mnT;mxT],[zeros(size(mnT));ones(size(mxT))],[1:length(mnT),(1:length(mxT))+1]');
            P = sortrows(P);
            while(P(2,2) ~= 1)
                P = P(2:end,:);
            end
            while(P(end-1,2) ~= 1)
                P = P(1:end-1,:);
            end
            
            PLen= ceil(max(P(2:2:end,1)-P(1:2:end-2,1))/fr)*2;
            PData = zeros(length(mxT)-2,PLen);
          
            for k = 1:length(mxT)-1
               id = k*2;
               
               mp = P(id-1,1) <= obj.Data.DataTime &  obj.Data.DataTime <= P(id,1);
               mID = P(id-1,1):fr:P(id,1);
               DD = double(obj.Data.DDist(mp) > 20).*(obj.Data.DDist(mp) - 20);
               dt = interp1(obj.Data.DataTime(mp),DD,mID);
               %figure(5);
               %plot(dt);
               
               PData(k,1:end/2) = 0;
               PData(k,end/2:end) =0;
               shift =  round(sum((1:length(dt)).*dt)/sum(dt));
               if(shift > 0 && shift < PLen/2)
                   PData(k,PLen/2-shift:length(mID)+PLen/2-shift-1) = dt;
               else
                   PData(k,:) = NaN;
                   warning('Warovani');
               end
                              
            end
            
           
            D1 = nanmean(PData(1:5,:));
            D2 = nanmean(PData(6:end,:));
            
           %figure(5)
           %plot(PData');
           %hold on
           %plot(D1','b','LineWidth',3);
           %plot(D2','r','LineWidth',3);
           %title(  obj.Data.FileName);
          % waitforbuttonpress
           hold off
           DIFF = nanmean(PData(1:5,:)) - nanmean(PData(6:end,:)) ;
           DM = DIFF ~=0;
            value=D2 / D1;
         end
        %}
        function value = get.VelCAvg15(obj)
            mask = obj.Data.DataTime(obj.VMin(:,1)) <= 5;
            value = mean(obj.VMin(mask,2));
        end
        
        function value = get.VelOAvg35(obj)
            mask = obj.Data.DataTime(obj.VMax(:,1)) > 10 & obj.Data.DataTime(obj.VMax(:,1)) < 15;
            value = mean(obj.VMax(mask,2));
        end
        
        function value = get.VelCAvg35(obj)
            mask = obj.Data.DataTime(obj.VMin(:,1)) > 10 & obj.Data.DataTime(obj.VMin(:,1)) < 15;
            value = mean(obj.VMin(mask,2));
        end
        
        function value = get.AmpAvg35(obj)
            mask = obj.Data.MaxT > 10 & obj.Data.MaxT < 15;
            value = mean(obj.Data.MaxV(mask,2));
        end
        
        function value = get.Vel10OAvg(obj)
            if (isempty(obj.VMax))
                value = NaN;
            elseif (length(obj.VMax) < 10)
                value = mean(obj.VMax(1:end,2));
            else
                value = mean(obj.VMax(1:10,2));
            end
        end
        
        function value = get.Vel10CAvg(obj)
            if (isempty(obj.VMin))
                value = NaN;
            elseif (length(obj.VMin) < 10)
                value = mean(obj.VMin(1:end,2));
            else
                value = mean(obj.VMin(1:10,2));
            end
        end
        
        function value = get.Vel10O3D1(obj)
            if (length(obj.VMax) < 10)
                value = NaN;
            else
                value = 1-mean(obj.VMax(8:10,2))/mean(obj.VMax(1:3,2));
            end
        end
        
        function value = get.Vel10C3D1(obj)
            if (length(obj.VMin) < 10)
                value = NaN;
            else
                value = 1-mean(obj.VMin(8:10,2))/mean(obj.VMin(1:3,2));
            end
        end
        
        function value = get.AmpAvgMin(obj)
            t = 5;
            m = obj.Data.MaxT < obj.Data.MaxT(end) - t;
            casy = obj.Data.MaxT(m);
            mins = [];
            for k= 1:length(casy)
                m = obj.Data.MaxT > casy(k) & obj.Data.MaxT < (casy(k)+t);
                value = mean(obj.Data.MaxV(m,2));
                mins = [mins,value];
            end
            value = min(mins);
        end
        
        function value = get.AmpAvgMax(obj)
            t = 3;
            m = obj.Data.MaxT < obj.Data.MaxT(end) - t;
            casy = obj.Data.MaxT(m);
            mins = [];
            for k= 1:length(casy)
                m = obj.Data.MaxT > casy(k) & obj.Data.MaxT < (casy(k)+t);
                value = mean(obj.Data.MaxV(m,2));
                mins = [mins,value];
            end
            value = max(mins);
        end
        
        function value = get.Amp3D1(obj)
            value = 1-obj.AmpAvg35 / obj.AmpAvg15;
        end
        
        function value = get.VelO3D1(obj)
            value = 1-obj.VelOAvg35 / obj.VelOAvg15;
        end
        
        function value = get.VelC3D1(obj)
            value = 1-obj.VelCAvg35 / obj.VelCAvg15;
        end
        
        function value = get.AmpMD1(obj)
            value = 1-obj.AmpAvgMin / obj.AmpAvg15;
        end
        
        function value = get.AmpMDM(obj)
            value = 1-obj.AmpAvgMin / obj.AmpAvgMax;
        end
        
        function value = get.AmpK(obj)
            p = length(obj.Data.MaxV);
            if(p > 30)
                p = 30;
            end
            [value s] = polyfit(linspace(0,1,p),obj.Data.MaxV(1:p)/max(obj.Data.MaxV(1:p)),1);
        end
        
        function value = get.NumOfOpen(obj)
            value = length(obj.Data.MaxV);
        end
        
        function value = get.FrqAvg(obj)
            casy = obj.Data.MaxT(obj.Data.MaxT < obj.Time);
            value = (length(casy)-1)/(casy(end) - casy(1));
        end
        
        function value = get.FrqStd(obj)
            casy = obj.Data.MaxT(obj.Data.MaxT < obj.Time);
            value = std(1./diff(casy));
        end
        
        function value = get.FrqReg(obj)
            casy = obj.Data.MaxT(obj.Data.MaxT < obj.Time);
            p = polyfit(casy(2:end),diff(casy),1);
            %{
             figure(1)
             plot(casy(2:end),diff(casy),'r*');
             hold on
             plot([0,15],polyval(p,[0 15]));
             hold off
             axis([0 15 0 1])
             waitforbuttonpress
             grid on
            %}
            value = p(1);
        end
        
        function value = get.Frq10(obj)
            casy = obj.Data.MaxT(obj.Data.MaxT < obj.Time);
            if (length(casy) < 10)
                casy = casy(1:end);
            else
                casy = casy(1:10);
            end
            
            if (isempty(casy))
                value = NaN;
            else
                value = (length(casy)-1)/(casy(end) - casy(1));
            end
        end
        
        function value = get.FrqAvg15(obj)
            casy = obj.Data.MaxT(obj.Data.MaxT <= 5);
            value = (length(casy)-1)/(casy(end) - casy(1));
        end
        
        function value = get.FrqAvg35(obj)
            casy = obj.Data.MaxT(obj.Data.MaxT <= 15 & obj.Data.MaxT >= 10 );
            if (~isempty(casy))
                value = (length(casy)-1)/(casy(end) - casy(1));
            else
                value = NaN;
            end
        end
        
        function value = get.Frq3D1(obj)
            value = 1-obj.FrqAvg35 / obj.FrqAvg15;
        end
        
        function value = get.Rythm(obj)
            RMS = [];
            n = obj.Data.Freq;
            for k = 1:length(obj.Data.DataDist)-n+1
                RMS(k) = sqrt(sum(obj.Data.DataDist(k:k+n-1).^2) / n) / mean(obj.Data.DataDist(k:k+n-1));
            end
            value = std(RMS);
        end
    end
    
    methods(Static)
        function obj = InitProperties(Data,time)
            obj = PDDataProp();
            obj.Data = Data;
            obj.Time = time;
            ComputeVelocity(obj);
        end
    end
    
    methods(Access = private)
        function obj = ComputeVelocity(obj)
            mn = zeros(size(obj.Data.MinV,1),4);
            mx = ones(size(obj.Data.MaxV,1),4);
            mn(:,1:2) = obj.Data.MinV;
            mn(:,3) = obj.Data.MinT;
            mx(:,1:2) = obj.Data.MaxV;
            mx(:,3) = obj.Data.MaxT;
            dt = cat(1,mn, mx);
            dt = sortrows(dt);
            obj.VMin = [];
            obj.VMax = [];
            
            for k = 2:size(dt,1)
                if(dt(k-1,4) == 1 && dt(k,4) ==0)
                    [m, id] = min(obj.Data.DDist(dt(k-1,1):dt(k,1)));
                    %m = m / (dt(k-1,2) - dt(k,2));
                    obj.VMin = [obj.VMin;id + dt(k-1,1)-1,m];
                elseif(dt(k-1,4) == 0 && dt(k,4) ==1)
                    [m, id] = max(obj.Data.DDist(dt(k-1,1):dt(k,1)));
                    %m = m / (dt(k-1,2) - dt(k,2));
                    obj.VMax = [obj.VMax;id + dt(k-1,1)-1,m];
                end
            end
        end
        
    end
    
end

