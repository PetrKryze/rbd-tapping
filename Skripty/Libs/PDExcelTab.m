classdef PDExcelTab < hgsetget
    %PDEXCELTAB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ExcelTab
        step
    end
    
    methods
        function obj = PDExcelTab(dts)
               
               obj.step = 4;
               numOfParams = length(dts);
               obj.ExcelTab{1} = 'ID';
               for k = 1:numOfParams
                 p = 2;
                 obj.ExcelTab{p+obj.step*(k-1)} = strcat(dts{k} ,'R1');
                 obj.ExcelTab{p+obj.step*(k-1)+1} = strcat(dts{k} ,'R2');
                 obj.ExcelTab{p+obj.step*(k-1)+2} = strcat(dts{k},'L1');
                 obj.ExcelTab{p+obj.step*(k-1)+3} = strcat(dts{k},'L2');
               end
   
        end
        function AddRow(obj,name,values)
           [PID hand cislo] = obj.ParseBKName(name);
           szEx = size(obj.ExcelTab);
           r = 0;
           for k = 1:szEx(1)
               if(strcmp(obj.ExcelTab{k,1},PID))
                    r = k;
                    break
               end
           end
           if(r == 0)
               r = szEx(1)+1;
               obj.ExcelTab{r,1} = PID;
           end
           shift = cislo+1;
           if(hand == 'L')
               shift = shift + 2;
           end
           for k = 1:length(values)
               obj.ExcelTab{r,shift+obj.step*(k-1)} = values(k);
           end
        end
        
        function Save(obj,filePath)
            xlswrite(filePath,obj.ExcelTab);
        end
    
    end
    methods(Static)
       
        function [ID hand cislo] = ParseBKName(name)
            cislo = str2num(name(end));
            nm = regexp(name, '_', 'split');
            ID = nm{1};
            zb = nm{2};
            hand = zb(1);            
        end
    end
    
end

