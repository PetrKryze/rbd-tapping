function output = cleanZeroValues(data)
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
if (any(data(:) <= 0)) % Contains invalid value
    if (~any(data(:) > 0)) % Does not contain any non-zero value
        output = NaN;
    else % Replace the invalid value with NaN
        output = data;
        output(output <= 0) = NaN;
    end
else
    output = data;  
end

end