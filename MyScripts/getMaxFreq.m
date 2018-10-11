function maxFreq = getMaxFreq(name, pd)
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%% Frequency analysis

time = pd.DataTime; % Sample time data

fs = 1/(time(2)); % Sampling frequency

% Cropping at 15 sec time
maxi = find(time > 15, 1);
if (isempty(maxi))
    maxi = length(time);
end

data = pd.DataDist(1:maxi);
data = data - mean(data); % Centering

N = 2^nextpow2(length(data));
Y = fft(data,N); % Fourier transform

Sy = abs(Y).^2; % Signal PSD - Periodogram

xdata = 0:fs/N:(fs/2) - (fs/N);

%% Plotting
% figure
% plot(xdata, Sy(1:N/2))
% grid on
% grid MINOR
% 
% title(sprintf('Frequency analysis - PSD: %s', name))
% ylabel('Power Spectral Density - |H(e^{j\theta})|^2')
% xlabel('Frequency - f [Hz]')

%% Printout
[~,maxFreqIndex] = max(Sy);
maxFreq = xdata(maxFreqIndex);

end
