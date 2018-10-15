classdef TestType
    enumeration
       Normal, Shaking, Counting 
    end
    methods
        function values = getTypeLabels(obj,hand)
            if strcmpi(hand,'L') || strcmpi(hand,'left')
                prefix = 'L';
            elseif strcmpi(hand,'R') || strcmpi(hand,'right') || strcmpi(hand,'P')
                prefix = 'P';
            else
               error('Invalid hand type!') 
            end
           switch(obj)
               case TestType.Normal
                   values = strcat(prefix,{'1','2'});
               case TestType.Shaking
                   values = strcat(prefix,{'S'});
               case TestType.Counting
                   values = strcat(prefix,{'C'});
               otherwise
                   error('Invalid measurement type!');
           end
        end
    end
end