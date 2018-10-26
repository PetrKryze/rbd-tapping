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
        MaxMed % Median of maximum amplitudes
        AmpMaxSlope % Decrement (slope) of linear regression of amplitude maxima
        MaxNRMSD % Normalised root mean square deviation of maximas
        MinNRMSD % Normalised root mean square deviation of minimas
        MinDwellTime % Median of time spent in minimas / valleys
        MinDwellTimeNRMSD % NRMSD of the valley time value
        Jitter % Frequency instability
        Shimmer % Amplitude instability
        FreqSlope % Linear regression slope of period's frequencies
        FreqSlopeMA % MA Smoothed lin.reg. slope of period's frequencies
        FreqNRMSD % NRMSD of period's frequencies
        OpenVelMed % Median of all opening velocities
        OpenVelSlope % Linear regression slope of opening velocities
        OpenVelNRMSD % NRMSD of opening velocities
        CloseVelMed % Median of all closing velocities
        CloseVelSlope % Linear regression slope of closing velocities
        CloseVelNRMSD % NRMSD of closing velocities
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
        function value = get.AmpMaxSlope(obj)
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
        
        %% Get jitter - frequency instability
        function value = get.Jitter(obj)
            periods = getPeriods(obj);
            Nper = length(periods);
            
            num = sum(abs(periods(2:end) - periods(1:end-1))) / (Nper-1);
            den = mean(periods);

            value = (num/den)*100;
        end
        
        %% Get shimmer - amplitude instability in percent
        function value = get.Shimmer(obj)            
            mins = getCroppedMin(obj);
            maxs = getCroppedMax(obj);
            
            % Calculate period's min-max amplitude difference
            Nper = min(size(mins,1),size(maxs,1));
            ampdif = zeros(Nper,1);
            for i = 1:Nper
                ampdif(i) = abs(maxs(i,2) - mins(i,2));
            end
            
            num = sum(abs(ampdif(2:end) - ampdif(1:end-1))) / (Nper-1);
            den = mean(ampdif);

            value = (num/den)*100;
        end
        
        %% Get freqslope - slope of linear regression of period frequencies
        function value = get.FreqSlope(obj)
           freqs = 1./getPeriods(obj);
           Nfreq = length(freqs);
           
           xval = (1:1:Nfreq)';
           P = polyfit(xval,freqs,1);
           
           value = P(1);           
           % Plotting
%            yval = polyval(P,xval);
%            close all
%            figure
%            plot(freqs)
%            hold on
%            grid on
%            xlim([0,Nfreq])
%            xlabel('Period number [-]')
%            ylabel('Period frequencies [Hz]')
%            plot(xval,yval)
%            title('Time evolution of period frequencies')            
        end
        
        %% Get freqslopeMA - moving average smoothed period frequencies
        function value = get.FreqSlopeMA(obj)
            whalfLen = 3; % SET WINDOW SIZE HERE
            per = getPeriods(obj);
            freqs = 1./getSmoothPeriods(per,whalfLen);
            
            Nfreq = length(freqs);
            
            xval = (1:1:Nfreq)';
            P = polyfit(xval,freqs,1);
            
            value = P(1);
        end
        
        %% Get freqNRMSD - normalised root mean square deviation of period frequencies
        function value = get.FreqNRMSD(obj)
            freqs = 1./getPeriods(obj);
            Nfreq = length(freqs);
            xval = (1:1:Nfreq)';
            
            value = nrmsd(xval,freqs);
        end
        
        %% Get OpenVelMed - median of finger opening velocity
        function value = get.OpenVelMed(obj)
            value = median(getOpenVelocities(obj));            
        end
        
        %% Get CloseVelMed - median of finger closing velocity
        function value = get.CloseVelMed(obj)
            value = median(getCloseVelocities(obj));
        end
        
        %% Get OpenVelSlope - lin.reg. slope of opening velocities
        function value = get.OpenVelSlope(obj)
            vel = getOpenVelocities(obj);
            Nvel = length(vel);
            
            xval = (1:1:Nvel)';
            P = polyfit(xval,vel,1);
            
            value = P(1);
        end
        
        %% Get CloseVelSlope - lin.reg. slope of closing velocities
        function value = get.CloseVelSlope(obj)
            vel = getCloseVelocities(obj);
            Nvel = length(vel);
            
            xval = (1:1:Nvel)';
            P = polyfit(xval,vel,1);
            
            value = P(1);
        end
        
        %% Get OpenVelNRMSD - NRMSD of opening velocities
        function value = get.OpenVelNRMSD(obj)
            vel = getOpenVelocities(obj);
            
            Nvel = length(vel);
            xval = (1:1:Nvel)';
            
            value = nrmsd(xval,vel);
        end
        
        %% Get CloseVelNRMSD - NRMSD of closing velocities
        function value = get.CloseVelNRMSD(obj)
            vel = getCloseVelocities(obj);
            
            Nvel = length(vel);
            xval = (1:1:Nvel)';
            
            value = nrmsd(xval,vel);
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

%% Normalised Root Mean Square Deviation
function out = nrmsd(x,y)
p = polyfit(x,y,1);
y_fit = polyval(p,x);

m = max(y) - min(y);
out = sqrt(sum((y_fit - y).^2) / length(y)) / m;
end

%% Returns Maximas cropped in regards to the time restriction
function mv = getCroppedMax(obj)
d = obj.Data;
if isempty(obj.SampleCut)
    mv = d.MaxV(:,:);
else
    mv = d.MaxV(d.MaxV(:,1) < obj.SampleCut,:);
end
end

%% Returns Minimas cropped in regards to the time restriction
function mv = getCroppedMin(obj)
d = obj.Data;
if isempty(obj.SampleCut)
    mv = d.MinV(:,:);
else
    mv = d.MinV(d.MinV(:,1) < obj.SampleCut,:);
end
end

%% Returns period times of all of the signal's periods
function periods = getPeriods(obj)
T = obj.Data.DataTime;
maxs = getCroppedMax(obj);

% Calculate periods
Nper = size(maxs,1) - 1;
periods = zeros(Nper,1);
for i = 1:Nper
    periods(i) = abs(T(maxs(i,1)) - T(maxs(i + 1,1)));
end
end

%% Returns period time averaged over multiple periods specified by wlen
function sp = getSmoothPeriods(periods,wlen)    
Nper = length(periods);
sp = zeros(Nper,1);
if wlen > ceil(Nper/2)
   error('Window length is too big!') 
end

for i = 1:Nper
    if (i-wlen) < 1
        sp(i) = mean(periods(1:i+wlen));
    elseif (i+wlen) > Nper
        sp(i) = mean(periods(i-wlen:end));
    else
        sp(i) = mean(periods(i-wlen:i+wlen));
    end
end
end

function V = getOpenVelocities(obj)
mins = getCroppedMin(obj);
maxs = getCroppedMax(obj);
T = obj.Data.DataTime;
N = min(size(mins,1),size(maxs,1));
V = zeros(N,1);

i = 1; % Max counter
j = 1; % Min counter
if maxs(1,1) < mins(1,1) % Maximum is first
    i = 2;
end

while i <= N
    dT = abs(T(maxs(i,1)) - T(mins(j,1))); % Opening time
    dD = abs(maxs(i,2) - mins(j,2)) / 100; % Opening distance in meters
    
    V(j) = dD/dT;
    i = i+1;
    j = j+1;
end
end

function V = getCloseVelocities(obj)
mins = getCroppedMin(obj);
maxs = getCroppedMax(obj);
T = obj.Data.DataTime;
N = min(size(mins,1),size(maxs,1));
V = zeros(N,1);

i = 1; % Max counter
j = 1; % Min counter
if mins(1,1) < maxs(1,1) % Minimum is first
    j = 2;
end

while j <= N
    dT = abs(T(mins(j,1)) - T(maxs(i,1))); % Closing time
    dD = abs(maxs(i,2) - mins(j,2)) / 100; % Closing distance in meters
    
    V(j) = dD/dT;
    i = i+1;
    j = j+1;
end
end






