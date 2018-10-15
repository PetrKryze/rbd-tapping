function [] = plotres3(d1,d2,nbin)
figure
narginchk(2,3)
if nargin < 3
    h = histfit(d1,[],'Normal');
else
    h = histfit(d1,nbin,'Normal');
end

hold on
h(1).FaceColor = [1 0 0];
h(1).FaceAlpha = 0.3;
h(2).Color = [1 0 0];

if nargin < 3
    h = histfit(d2,[],'Normal');
else
    h = histfit(d2,nbin,'Normal');
end
h(1).FaceColor = [0 0 1];
h(1).FaceAlpha = 0.3;
h(2).Color = [0 0 1];

grid on

title('Statistical Analysis 3 result')
xlabel('Property values')
ylabel('Sample counts [-]')

end