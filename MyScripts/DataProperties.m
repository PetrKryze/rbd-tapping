classdef DataProperties
    %{
    Author: Petr Kr��e
    Email: petr.kryze@gmail.com
    ---------------------------------------
    Data properties class - gets Data object as an input and performs
    calculations of various parameters on the input data
    %}
    
    %% Properties
    properties
        MaxMed
        AmpMaxDec
        MaxNRMSD
        MinNRMSD
        MinDwellTime
    end
    
    properties (GetAccess = private)
        Data
        SampleCut
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = DataProperties(Data,TimeCut)            
            if nargin > 0
                if class(Data) == 'PDData'
                    obj.Data = Data;
                else
                    error('Input argument is not PDData object!')
                end
            
                if nargin > 1
                    f = find(obj.Data.DataTime > TimeCut);
                    if isempty(f)
                        obj.SampleCut = [];
                    else
                        obj.SampleCut = f(1);
                    end
                else
                    obj.SampleCut = [];
                end
            end
        end
        
        %% Get MaxAvg - median of maxima
        function value = get.MaxMed(obj)
            mv = getCroppedMax(obj);
            value = median(mv(:,2));
        end
        
        %% Get AmpMaxDec
        function value = get.AmpMaxDec(obj)
            d = obj.Data;
            mv = getCroppedMax(obj); 
            
            xval = d.DataTime(mv(:,1));
            p = polyfit(xval',mv(:,2)',1);
            
            % Control plotting
            %             f = polyval(p,xval');
            %             figure('Name','Maximum Amplitude Decrement')
            %             plot(d.DataTime,d.DataDist)
            %             hold on
            %             grid on
            %             scatter(xval, d.MaxV(:,2), 'm', 'x')
            %             plot(xval',f,'LineStyle','--','Color','black')
            %             hold off
            %             title('Maximum Amplitude Decrement')
            %             xlabel('Time [s]')
            %             ylabel('Distance data [cm]')
            %             legend('Marker distance','Peaks',sprintf('Linear regression: k=%.3e', p(1)),'Location','southeast')
            %
            value = p(1);
        end
        
        %% Get MaxNRMSD - Normalised RMS Deviation of Maximum values
        function value = get.MaxNRMSD(obj)
            d = obj.Data;
            mv = getCroppedMax(obj);
            value = nrmsd(d.DataTime(mv(:,1)),mv(:,2));
        end
        
        %% Get MinNRMSD - Normalised RMS Deviation of Minimum values
        function value = get.MinNRMSD(obj)
            d = obj.Data;
            mv = getCroppedMin(obj);
            value = nrmsd(d.DataTime(mv(:,1)),mv(:,2));
        end
        
        %% Get minima dwell time
        function value = get.MinDwellTime(obj)
            value = 0;
        end
        
        %% Set cropping time
        function obj = set.SampleCut(obj,TimeCut)
            % Find index of the first sample of time larger than the
            % threshold value, if applicable
            f = find(obj.Data.DataTime > TimeCut);
            if isempty(f)
                obj.SampleCut = [];
            else
                obj.SampleCut = f(1);
            end
        end
        
    end
    
end

function out = nrmsd(x,y)
p = polyfit(x,y,1);
y_fit = polyval(p,x);

m = max(y) - min(y);
out = sqrt(sum((y_fit - y).^2) / length(y)) / m;
end

function mv = getCroppedMax(obj)
d = obj.Data;
if isempty(obj.SampleCut)
    mv = d.MaxV(:,:);
else
    mv = d.MaxV(d.MaxV(:,1) < obj.SampleCut,:);
end
end

function mv = getCroppedMin(obj)
d = obj.Data;
if isempty(obj.SampleCut)
    mv = d.MinV(:,:);
else
    mv = d.MinV(d.MinV(:,1) < obj.SampleCut,:);
end
end

