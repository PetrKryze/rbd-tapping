classdef PDData < hgsetget
    %PDDATA Summary of this class goes here
    %   Detailed explanation goes here
    %% Properties
    properties(SetAccess=private,GetAccess=private)
        fullPath
        data
        allDataDist
    end
    
    properties(SetAccess=public)
        Freq
        DataDist
        DataTime
        Data
        DDist
        MinT
        MaxT
        MaxV
        MinV
        ExT
        ExV
        FileName
        FullFileName
        ErrorMask
        FromTime
        ToTime
        From
        To
    end

    %% Methods - Getters and Setters
    methods
        function value = get.Data(obj)
            value = obj.data(obj.From:obj.To,:);
        end
        
        function value = get.Freq(obj)
            value = median(obj.Data(2:end,1)- obj.Data(1:end-1,1));
            value = ceil(1/value);
        end
        
        function value = get.ExT(obj)
            mxT = cat(2,obj.MaxT,ones(size(obj.MaxT)));
            mnT = cat(2,obj.MinT,zeros(size(obj.MinT)));
            P = cat(1,mxT,mnT);
            value = sortrows(P);
        end
        
        function value = get.ExV(obj)
            mxT = cat(2,obj.MaxV,ones(size(obj.MaxV,1),1));
            mnT = cat(2,obj.MinV,zeros(size(obj.MinV,1),1));
            P = cat(1,mxT,mnT);
            value = sortrows(P);
        end
        
        function value = get.DataDist(obj)
            value = sqrt( sum((obj.Data(:,2:4)-obj.Data(:,5:7)).^2,2));
        end
        
        function value = get.allDataDist(obj)
            value = sqrt( sum((obj.data(:,2:4)-obj.data(:,5:7)).^2,2));
        end
        
        function value = get.DataTime(obj)
            value = obj.Data(:,1);
        end
        
        function value = get.FileName(obj)
            [path, value, ext] = fileparts(obj.fullPath);
        end
        
        function value = get.FullFileName(obj)
            [path, v, ext] = fileparts(obj.fullPath);
            value = [v,ext];
        end
        
        function value = get.ErrorMask(obj)
            dd = obj.Data(2:end,1)- obj.Data(1:end-1,1);
            value = dd > (obj.Period * 1.4);
            value(2:end+1) = value;
            value(1) = false;
        end
        
        function value = get.MaxT(obj)
            value = obj.DataTime(obj.MaxV(:,1)) ;
        end
        
        function value = get.MinT(obj)
            value = obj.DataTime(obj.MinV(:,1)) ;
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
        
        %% No idea
        function obj = AddValue(obj,time,val)
            
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
            
            try % Tries to load data to object from MAT file
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
                    end % Reading of the file
                else
                    while ischar(tline) % Reading of the file
                        tline = fgetl(fid);
                        if(ischar(tline))
                            A = sscanf(tline,'frame,%*f,%f,%*f,%*f,%f,%f,%f,%*f,%f,%f,%f,%*f');
                            if(length(A) == 7)
                                obj.data = [obj.data;A(1)*1000,A(2:7)'*100];
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
        
        %% Compute Extremes
        function [MinVal MaxVal] = ComputeExtremas(DataDist,windowsize,minT)
            vzorky = windowsize;
            % pdata mean vector on window
            pdata = zeros(size(DataDist));
            pdata(1:vzorky) = mean(DataDist(1:vzorky));
            pdata(end-vzorky+1:end) = mean(DataDist(end-vzorky+1:end));
            for k=vzorky+1:length(pdata)-vzorky
                pdata(k) = mean(DataDist(k-vzorky:k+vzorky));
            end
            % pmin minimum in window
            pmin = zeros(size(DataDist));
            pmin(1:vzorky) = mean(DataDist(1:vzorky));
            pmin(end-vzorky+1:end) = mean(DataDist(end-vzorky+1:end));
            for k=vzorky+1:length(pmin)-vzorky
                pmin(k) = min(DataDist(k-vzorky:k+vzorky));
            end
            
            minmask = DataDist < pdata & DataDist < pmin + minT;
            
            %maxmask = DataDist > min(Datadist) + 1.5;
            maxmask = DataDist > pdata;%min(handles.ActualData.Datadist) + 1.5;
            
            
            typ = 0; % 0 nic 1 min 2 max
            start = 0;
            nmini = [];
            nmaxi = [];
            for k = 1:length(minmask)
                if(typ == 0 && minmask(k))
                    typ = 1;
                    start = k;
                end
                if(typ == 0 && maxmask(k))
                    typ = 2;
                    start = k;
                end
                if(typ == 1 && maxmask(k))
                    [X I] = min(DataDist(start:k-1));
                    nmini = [nmini;[I+start-1,X]];
                    typ = 2;
                    start = k;
                end
                if(typ == 2 && minmask(k))
                    [X,I]= max(DataDist(start:k-1));
                    if(I > 1 && I < length(DataDist(start:k-1)))
                        XM = mean(DataDist(I-1:I+1));
                    else
                        XM = X;
                    end
                    nmaxi = [nmaxi;[I+start-1,X]];
                    typ = 1;
                    start = k;
                end
                
                
            end
            
            MaxVal = sortrows(nmaxi);
            MinVal = sortrows(nmini);
            if(MaxVal(1,1) < MinVal(1,1))
                MaxVal = MaxVal(2:end,:);
            end
            
            % nakresleni
            %x = (1:length(DataDist))/60;
            %plot(x,DataDist)
            %hold on;
            %plot(x(minmask),4,'sg','MarkerSize',2,'MarkerFaceColor','g');
            %plot(x(maxmask),4,'sr','MarkerSize',2,'MarkerFaceColor','r');
            %xlim([10.5 14.5])
            %xlabel('Èas [s]');
            %ylabel('Vzdálenost znaèek [cm]');
            %plot(MinVal(:,1)/60,MinVal(:,2),'g*');
            %plot(MaxVal(:,1)/60,MaxVal(:,2),'r*');
            %hold off;
        end
    end
    
    %% Normal Methods
    methods
        function obj = ReLoad(obj)
            if(exist(obj.fullPath, 'file') == 2)
                obj.Load(obj.fullPath);
            end 
        end
        
        function newObj = Copy(obj)
            newObj = PDData();
            newObj.data = obj.data;
            newObj.From = obj.From;
            newObj.To = obj.To;
            newObj.fullPath = obj.fullPath;
            newObj.ComputeAll();
            
        end
        
        function ComputeAll(obj)
            obj.DDist = obj.FirstDerivative(obj.DataTime,obj.DataDist);
            [f n ex] = fileparts(obj.fullPath);
            if(exist(fullfile(f,[n,'.mat']),'file'))
                M = load(fullfile(f,[n,'.mat']));
                obj.MinV = M.M.MinV;
                obj.MaxV = M.M.MaxV;
            else
                [obj.MinV, obj.MaxV] = obj.ComputeExtremas(obj.DataDist,30,1.5);
            end
        end
        
        function SaveMinMax(obj)
            M.MinV = obj.MinV;
            M.MaxV = obj.MaxV;
            [f, n, ex] = fileparts(obj.fullPath);
            save(fullfile(f,[n,'.mat']),'M');
        end
        
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
        
        function SaveToPath(obj,path,startTime,dataLength)
            if(~exist('startTime','var'))
                startTime = 0;
            end
            if(~exist('dataLength','var'))
                dataLength = obj.DataTime(end)-startTime;
            end
            obj.Save(fullfile(path,obj.FullFileName),startTime,dataLength)
        end
        
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
        
        function AddPoint(obj,point)
            obj.data = cat(1,obj.data(obj.data(:,1) <= point(1),:) ,[point(1) point(2) 0 0 0 0 0], obj.data(obj.data(:,1) > point(1),:));
            obj.To = obj.To + 1;
            obj.ComputeAll();
        end
        
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