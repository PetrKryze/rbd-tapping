classdef DataProperties
    %{
    Author: Petr Krýže
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
        MinDwellTimeNRMSD
    end
    
    properties (GetAccess = private)
        Data
        TimeCut
    end
    
    properties (Dependent, GetAccess = private)
        SampleCut
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = DataProperties(Data,TimeCut)
            narginchk(1,2);
            
            if class(Data) == 'PDData'
                obj.Data = Data;
            else
                error('Input argument is not PDData object!')
            end
            
            if nargin < 2
                obj.TimeCut = [];
            else
                obj.TimeCut = TimeCut;
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
            %% Init
            percThreshold = 0.01; % Valley slopes threshold
            plotting = 0;
            valleys = getValleys(obj, percThreshold, plotting);

            %% Output
            value = median(valleys(:,2),'omitnan');
            if plotting
                pause
                close(gcf)
            end
        end
        
        %% Get minima dwell time linear regression NRMSD
        function value = get.MinDwellTimeNRMSD(obj)
            %% Init
            percThreshold = 0.01; % Valley slopes threshold
            plotting = 0;
            valleys = getValleys(obj, percThreshold, plotting);
            
            %% Output
            value = nrmsd(valleys(:,1),valleys(:,2));
        end
        
        %% Set cropping time
        function value = get.SampleCut(obj)
            % Find index of the first sample of time larger than the
            % threshold value, if applicable
            if isempty(obj.TimeCut)
                value = [];
            else                
                f = find(obj.Data.DataTime > obj.TimeCut);
                if isempty(f)
                    value = [];
                else
                    value = f(1);
                end
            end
        end
        
    end
    
end

function valleys = getValleys(obj, percThreshold, plotting)
if nargin <= 2
   plotting = 0; 
end
%% Init
% percThreshold = Valley slopes threshold
d = obj.Data;
dist = d.DataDist;
MaxV = getCroppedMax(obj);
MinV = getCroppedMin(obj);

if MinV(1,1) < MaxV(1,1) % last Min is before Max
    i0 = 2;
else
    i0 = 1;
end

if MaxV(end,1) > MinV(end,1) % last Max is after Min
    iend = size(MinV,1);
else
    iend = size(MinV,1) - 1;
end

%% Plotting
if plotting
    figure
    plot(d.DataDist)
    xlim([0,d.To])
    grid on
    hold on
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    title('Minima Valley illustration plot')
    xlabel('Sample [-]')
    ylabel('Mark distance [cm]')
end

%% Main Loop
valleys = zeros(iend - i0 + 1,2);
for i = i0:iend
    min = MinV(i,:);
    
    max1 = MaxV(i - i0 + 1,:);
    max2 = MaxV(i - i0 + 2,:);
    
    d1 = abs(max1(2) - min(2));
    d2 = abs(max2(2) - min(2));
    
    j = 1;
    rim1t = d.DataTime(min(1));
    while(1)
        rim1val = dist(min(1) - j);
        if rim1val > (min(2) + (percThreshold * d1))
            rim1ix = min(1) - j;
            rim1t = d.DataTime(rim1ix);
            break;
        end
        j = j + 1;
    end
    
    j = 1;
    rim2t = d.DataTime(min(1));
    while(1)
        rim2val = dist(min(1) + j);
        if rim2val > (min(2) + (percThreshold * d2))
            rim2ix = min(1) + j;
            rim2t = d.DataTime(rim2ix);
            break;
        end
        j = j + 1;
    end
    
    valleys(i - i0 + 1,1) = min(1); % Valley index - minima position
    valleys(i - i0 + 1,2) = abs(rim2t - rim1t); % Valley length
    if plotting
        scatter(min(1),min(2),'x','r')
        % Plotting the valley
        if rim1val > dist(min(1)) + (d1*percThreshold)
            rim1val = dist(min(1)) + (d1*percThreshold);
        end
        if rim2val > dist(min(1)) + (d2*percThreshold)
            rim2val = dist(min(1)) + (d2*percThreshold);
        end
        line([rim1ix,rim2ix],[rim1val,rim2val],'Color','red','LineWidth',2)
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


