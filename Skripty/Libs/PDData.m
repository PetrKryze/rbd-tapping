classdef PDData < hgsetget
    %PDDATA Summary of this class goes here
    %   Detailed explanation goes here
    %% Properties
    properties(SetAccess=private,GetAccess=private)
        fullPath % Full path to file
        data % Raw data from file
        allDataDist % Finger distance data from whole data set
    end
    
    properties(SetAccess=public)
        Freq % Approximate of sampling frequency
        DataDist % Finger distance data accoring to Data
        DataTime % Timestamps of the samples
        Data % Data selected according to FROM - TO
        DDist % First approximative derivative -> Velocity of fingers
        MinT % Times of the minimums
        MaxT % Times of the maximums
        MaxV % Values of maximas
        MinV % Values of minimas
        ExT % Concatenated times of extremes
        ExV % Concatented values and times of extremes
        FileName
        FullFileName
        ErrorMask
        FromTime % Time of first sample
        ToTime % Time of last sample
        From % Index of first sample
        To % Index of last sample
    end
    
    %% Methods - Getters and Setters
    methods
        function value = get.Data(obj)
            value = obj.data(obj.From:obj.To,:);
        end
        
        function value = get.Freq(obj)
            % Computes difference between time samples (period), medians them
            value = median(obj.Data(2:end,1)- obj.Data(1:end-1,1));
            value = ceil(1/value);
        end
        
        function value = get.ExT(obj)
            mxT = [obj.MaxT, ones(size(obj.MaxT))];
            mnT = [obj.MinT, zeros(size(obj.MinT))];
            P = [mxT ; mnT];
            value = sortrows(P);
        end
        
        function value = get.ExV(obj)
            mxT = [obj.MaxV,ones(size(obj.MaxV,1),1)];
            mnT = [obj.MinV,zeros(size(obj.MinV,1),1)];
            P = [mxT ; mnT];
            value = sortrows(P);
        end
        
        function value = get.DataDist(obj)
            % Euclidean distance of two points in 3D
            % d = sqrt((ax - bx)^2 + (ay - by)^2 + (az - bz)^2)
            value = sqrt(sum((obj.Data(:,2:4) - obj.Data(:,5:7)).^2,2));
        end
        
        function value = get.allDataDist(obj)
            value = sqrt(sum((obj.data(:,2:4) - obj.data(:,5:7)).^2,2));
        end
        
        function value = get.DataTime(obj)
            value = obj.Data(:,1);
        end
        
        function value = get.FileName(obj)
            [~, value, ~] = fileparts(obj.fullPath);
        end
        
        function value = get.FullFileName(obj)
            [~, v, ext] = fileparts(obj.fullPath);
            value = [v,ext];
        end
        
        function value = get.ErrorMask(obj)
            dd = obj.Data(2:end,1)- obj.Data(1:end-1,1);
            value = dd > (obj.Period * 1.4);
            value(2:end+1) = value;
            value(1) = false;
        end
        
        function value = get.MaxT(obj)
            value = obj.DataTime(obj.MaxV(:,1));
        end
        
        function value = get.MinT(obj)
            value = obj.DataTime(obj.MinV(:,1));
        end
        
        function value = get.FromTime(obj)
            value = obj.data(obj.From,1);
        end
        
        function value = get.ToTime(obj)
            value = obj.data(obj.To,1);
        end
        
        function SetFromTime(obj,val)
            [m,id] = max(obj.data(:,1) >= val);
            if(m == 1 && obj.To >= id)
                obj.From = id;
            end
            if(m == 0 && ~isempty(obj.data(:,1)))
                obj.From = 1;
            end
        end
        
        function SetToTime(obj,val)
            [m,id] = min(obj.data(:,1) <= val);
            
            if(m == 0 && obj.From <= id)
                obj.To = id;
            end
            if(m == 1)
                obj.To = length(obj.data(:,1));
            end
        end
        
        %% Median filter
        function obj = MedFilt(obj,n)
            %obj.data(:,2:end) = medfilt1(obj.data(:,2:end),n);
            obj.data(:,2) = medfilt1( sqrt( sum((obj.data(:,2:4)-obj.data(:,5:7)).^2,2)),n);
            obj.data(:,3:end) = zeros(size(obj.data,1),5);
            obj.ComputeAll();
        end
        
    end
    
    %% Static methods
    methods( Static )
        %% Load
        function obj = Load(dataPath)
            % Object init
            obj = PDData();
            obj.fullPath = dataPath;
            obj.data = [];
            
            try % Tries to load data to object from DAT file using load()
                obj.data = load(obj.fullPath);
            catch err
                % In case the data could not be loaded
                % (data is not a rectangular ASCII table)
                fid = fopen(obj.fullPath);
                tline = fgetl(fid);
                if (strcmp(tline,'#BradykAn_Data_Set'))
                    while ischar(tline)
                        tline = fgetl(fid);
                        
                        if(ischar(tline))
                            if(sum(tline == ';') < 9)
                                continue
                            end
                            
                            tline = strrep(tline, ',', '.');
                            A = sscanf(tline,'%f;%*f;%f;%f;%f;%*f;%f;%f;%f;');
                            
                            if(length(A) >= 7)
                                obj.data = [obj.data; A(1)*1000, A(2:7)'*100];
                            end
                        end
                    end
                end
                fclose(fid);
            end
            
            % Offsets the time to start from zero and be in seconds
            obj.data(:,1) = (obj.data(:,1) - obj.data(1,1))/1000;
            obj.From = 1;
            obj.To = size(obj.data,1);
            obj.ComputeAll();
        end
        
        %% First Derivative
        function DDist = FirstDerivative(DataTime,DataDist)
            DTime = zeros(size(DataTime));
            DTime(2:end) = diff(DataTime);
            DTime(1) = DTime(2);
            
            DDist = zeros(size(DataDist));
            DDist(2:end) = diff(DataDist);
            DDist(1) = DDist(2);
            DDist = DDist ./ DTime;
        end
        
        %% Compute Extremes Old
        function [MinVal, MaxVal] = ComputeExtremasOld(DataDist,windowsize,minT)
            Nsamples = windowsize;
            
            pdata = zeros(size(DataDist)); % Allocation
            pdata(1:Nsamples) = mean(DataDist(1:Nsamples)); % Fill with mean value
            pdata(end-Nsamples+1:end) = mean(DataDist(end-Nsamples+1:end));
            
            for n = Nsamples+1:length(pdata)-Nsamples
                pdata(n) = mean(DataDist(n-Nsamples:n+Nsamples));
            end
            
            % pmin minimum in window
            pmin = zeros(size(DataDist));
            pmin(1:Nsamples) = mean(DataDist(1:Nsamples));
            pmin(end-Nsamples+1:end) = mean(DataDist(end-Nsamples+1:end));
            for n=Nsamples+1:length(pmin)-Nsamples
                pmin(n) = min(DataDist(n-Nsamples:n+Nsamples));
            end
            
            minmask = DataDist < pdata & DataDist < pmin + minT;
            
            %maxmask = DataDist > min(Datadist) + 1.5;
            maxmask = DataDist > pdata;%min(handles.ActualData.Datadist) + 1.5;
            
            typ = 0; % 0 nic 1 min 2 max
            start = 0;
            nmini = [];
            nmaxi =[];
            for n = 1:length(minmask)
                if(typ == 0 && minmask(n))
                    typ = 1;
                    start = n;
                end
                if(typ == 0 && maxmask(n))
                    typ = 2;
                    start = n;
                end
                if(typ == 1 && maxmask(n))
                    [X, I] = min(DataDist(start:n-1));
                    nmini = [nmini;[I+start-1,X]];
                    typ = 2;
                    start = n;
                end
                if(typ == 2 && minmask(n))
                    [X,I]= max(DataDist(start:n-1));
                    if(I > 1 && I < length(DataDist(start:n-1)))
                        XM = mean(DataDist(I-1:I+1));
                    else
                        XM = X;
                    end
                    nmaxi = [nmaxi;[I+start-1,X]];
                    typ = 1;
                    start = n;
                end
            end
            
            MaxVal = sortrows(nmaxi);
            MinVal = sortrows(nmini);
            if(MaxVal(1,1) < MinVal(1,1))
                MaxVal = MaxVal(2:end,:);
            end
            
        end
        
        %% Compute Extremes
        function [mins, maxs] = ComputeExtremas(DataDist)
            Ndata = length(DataDist);
            Nrange = 100; % Number of values to calculate the prominence threshold from
            widthThrCoef = 0.2; % Modifies the threshold for peak width
            promThrCoef = 0.15; % Modifies the threshold for peak prominence
            
            mData = DataDist - mean(DataDist);
            posN = floor(Nrange*(length(mData(mData > 0))/Ndata));
            negN = floor(Nrange*(length(mData(mData < 0))/Ndata));
            
            s = sort(DataDist,'descend');
            promThr = mean(s(1:posN)) - mean(s(end-negN-1:end));
            promThr = promThr * promThrCoef; % Prominence value threshold

            % Find maximum peaks
            [maxv, maxix, width, ~] = findpeaks(DataDist,'MinPeakDistance',10,'MinPeakProminence',promThr);
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
                mins = [mins; [maxs(end,1) + minix_end - 1, minv_end]];
            else % Last found extreme is a minimum
                [maxv_end, maxix_end] = max(DataDist(mins(end,1):end));
                maxs = [maxs; [mins(end,1) + maxix_end - 1, maxv_end]];
            end
        end
        
    end
    
    %% Normal Methods
    methods
        %% Reload
        function obj = ReLoad(obj)
            if(exist(obj.fullPath, 'file') == 2)
                obj.Load(obj.fullPath);
            end
        end
        
        %% Copy object
        function newObj = Copy(obj)
            newObj = PDData();
            newObj.data = obj.data;
            newObj.From = obj.From;
            newObj.To = obj.To;
            newObj.fullPath = obj.fullPath;
            newObj.ComputeAll();           
        end
        
        %% Compute all
        function ComputeAll(obj)
            obj.DDist = obj.FirstDerivative(obj.DataTime,obj.DataDist);
            % Get path to data folder and file name
            [f, n, ~] = fileparts(obj.fullPath);
            if(exist(fullfile(f,[n,'.mat']),'file'))
                M = load(fullfile(f,[n,'.mat']));
                obj.MinV = M.M.MinV;
                obj.MaxV = M.M.MaxV;
            else
                % Legacy function Arguments - distance data, windowsize, minT
                %[mins, maxs] = obj.ComputeExtremasOld(obj.DataDist,30,1.5);
                [mins, maxs] = obj.ComputeExtremas(obj.DataDist);                
                obj.MinV = mins;
                obj.MaxV = maxs;                
                %% Plotting for debugging
                %{
                close all
                figure(1)
                subplot(211)
                plot(obj.DataDist)
                hold on
                grid on
                scatter(maxs2(:,1), maxs2(:,2), 'm', 'o')
                scatter(mins2(:,1), mins2(:,2), 'r', 'o')
                
                p = polyfit(maxs2(:,1)',maxs2(:,2)',1);
                f = polyval(p,maxs2(:,1)');
                plot(maxs2(:,1)',f,'--')
                title('New Function')
                hold off
                
                subplot(212)
                plot(obj.DataDist)
                hold on
                grid on
                scatter(maxs1(:,1), maxs1(:,2), 'm', 'o')
                scatter(mins1(:,1), mins1(:,2), 'r', 'o')
                title('Old Function')
                hold off
                set(gcf,'Position',[20 60 800 750])
                close
                %}
            end
        end
        
        %% Save minimas and maximas
        function SaveMinMax(obj)
            M.MinV = obj.MinV;
            M.MaxV = obj.MaxV;
            [f, n, ex] = fileparts(obj.fullPath);
            save(fullfile(f,[n,'.mat']),'M');
        end
        
        %% Save
        function Save(obj,fullPath,startTime,dataLength)
            if(~exist('fullPath','var'))
                fullPath = obj.fullPath;
            end
            if(~exist('startTime','var'))
                startTime = 0;
            end
            if(~exist('dataLength','var'))
                dataLength = obj.DataTime(end)-startTime;
            end
            
            dt = obj.Data;
            datamask = dt(:,1) >= startTime & dt(:,1) <= (startTime + dataLength);
            datasave = dt(datamask,:) - startTime;
            datasave(:,1) = datasave(:,1) * 1000;
            dlmwrite(fullPath,datasave,'precision', 16,'delimiter', ' ','newline', 'pc');
        end
        
        %% Save to path
        function SaveToPath(obj,path,startTime,dataLength)
            if(~exist('startTime','var'))
                startTime = 0;
            end
            if(~exist('dataLength','var'))
                dataLength = obj.DataTime(end)-startTime;
            end
            obj.Save(fullfile(path,obj.FullFileName),startTime,dataLength)
        end
        
        %% Clear Bad values
        function ClearBadValues(obj,prah)
            frT = obj.FromTime;
            toT = obj.ToTime;
            m = diff(obj.allDataDist) < prah;
            m = [true;m];
            obj.data = obj.data(m,:);
            obj.SetFromTime(frT);
            obj.SetToTime(toT);
            obj.ComputeAll();
        end
        
        %% Add data point
        function AddPoint(obj,point)
            obj.data = cat(1,obj.data(obj.data(:,1) <= point(1),:) ,[point(1) point(2) 0 0 0 0 0], obj.data(obj.data(:,1) > point(1),:));
            obj.To = obj.To + 1;
            obj.ComputeAll();
        end
        
        %% Add minima maxima
        function AddMinMax(obj,point)
            mi = sum(obj.ExT(:,1) <= point(1));
            [pks,locs] = findpeaks(obj.DataDist(obj.ExV(mi,1):obj.ExV(mi+1,1)));
            obj.DataTime(locs + obj.ExV(mi,1) -1);
            [mv, mid]=min(abs(obj.DataTime(locs + obj.ExV(mi,1) -1) - point(1)));
            maxID = obj.ExV(mi,1)+locs(mid)-1;
            exID = sum(obj.ExV(:,1) <= maxID);
            if(obj.ExV(exID,3) == 1)
                [mv, mid] = min(obj.DataDist(obj.ExV(exID,1):maxID));
                minID  = obj.ExV(exID,1) - 1 +mid;
            else
                [mv, mid] = min(obj.DataDist(maxID:obj.ExV(exID+1,1)));
                minID  = maxID - 1 +mid;
            end
            miV = [minID,obj.DataDist(minID)];
            mxV = [maxID,obj.DataDist(maxID)];
            mi = sum(obj.MinV(:,1) <= minID);
            mx = sum(obj.MaxV(:,1) <= maxID);
            if(mi > 0)
                obj.MinV = cat(1,obj.MinV(1:mi,:),miV,obj.MinV(mi+1:end,:));
            end
            if(mx > 0)
                obj.MaxV = cat(1,obj.MaxV(1:mx,:),mxV,obj.MaxV(mx+1:end,:));
            end
            
        end
        
        %% Remove data point
        function RemovePoint(obj,point)
            a1 = obj.data(obj.data(:,1) <= point(1),:);
            a2 = obj.data(obj.data(:,1) > point(1),:);
            if(size(a2,1) > 1)
                obj.data = cat(1,a1,a2(2:end,:) );
                obj.To = obj.To -1;
            end
            if(size(a2,1) == 1)
                obj.data = a1;
                obj.To = obj.To -1;
            end
            obj.ComputeAll();
            
        end
        
        %% Remove minima / maxima
        function RemoveMinMax(obj, point)
            mi = sum(obj.MinT <= point(1));
            mx = sum(obj.MaxT <= point(1));
            if(mi > 0)
                obj.MinV = cat(1,obj.MinV(1:mi-1,:),obj.MinV(mi+1:end,:));
            end
            if(mx > 0)
                obj.MaxV = cat(1,obj.MaxV(1:mx-1,:),obj.MaxV(mx+1:end,:));
            end
            
        end
    end
    
end