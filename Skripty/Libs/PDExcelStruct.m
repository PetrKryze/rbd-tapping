classdef PDExcelStruct < dynamicprops
    %PDEXCELSTRUCT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
         ExcelTab
         AllProps
    end
    methods(Static)
        function obj = Load(path)
            [D T RAW ] = xlsread(path);
            obj = PDExcelStruct(RAW);
        end
        
        
    end
    methods
        
        function row = GetRow(obj,id)
           for k = 1:length(obj.AllProps)
               p = obj.(obj.AllProps{k});
               row{k} = p(id);
           end
        end
        function newObj = GetSubSet(obj,id)
            if(length(id) == 1)
                id=id+1;
            end
            if(length(id) > 1 )
                id = [true;id];
            end
            newObj = PDExcelStruct(obj.ExcelTab(id,:));
        end
        function newObj = Merge(obj,pdExcel)
            sameID = [];
            exTab =obj.ExcelTab;
            for m = 1:length(pdExcel.AllProps)
                for k = 1:length(obj.AllProps)
                    if(strcmp(obj.AllProps(k),pdExcel.AllProps(m)))
                        if ~isempty(sameID) > 1
                            error(['More same col names ',obj.AllProps{k}]);
                        end          
                        sameID = obj.AllProps{k};
                        sameIDi = m;
                        sameIDt = k;
                    end
                end
            end
            if isempty(sameID)
                error('No same ID');
            end            
            for k = 1:length(pdExcel.AllProps)
               if( ~strcmp(pdExcel.AllProps{k},sameID))
                  %obj.addprop(pdExcel.AllProps{k});
                  exTab{1,size(exTab,2)+1} = pdExcel.AllProps{k};  
                  exTab(2:end,size(exTab,2))  = repmat({NaN},size(exTab,1)-1,1);;
               end
            end
            
            
            isVisited = zeros(size(pdExcel.(sameID))) == 1;
            for k = 1:length(obj.(sameID))
               hledam = obj.(sameID)(k);
               mask = strcmp(pdExcel.(sameID),hledam);
               mid = find(mask == 1);
               if(length(mid) > 1)
                   error(['More same names: ',hledam]);
               end
               if(~isempty(mid))
                    exTab(k+1,(length(obj.AllProps) + 1):length(obj.AllProps)+length(pdExcel.AllProps)-1 ) =...
                     pdExcel.ExcelTab(mid+1,1:length(pdExcel.AllProps)~=sameIDi);
                    isVisited(mid) = 1;
                   
               end
            end
            isVisited = [true;isVisited];
            szET= size(exTab,1)+1;
            exTab(szET:szET+sum(~isVisited)-1,(length(obj.AllProps) + 1):length(obj.AllProps)+length(pdExcel.AllProps)-1 ) =...
                     pdExcel.ExcelTab(~isVisited,1:length(pdExcel.AllProps)~=sameIDi);
            exTab(szET:szET+sum(~isVisited)-1,sameIDt) = pdExcel.ExcelTab(~isVisited,sameIDi);
            newObj = PDExcelStruct(exTab);
        end
       function Save(obj,strName)
            xlswrite(strName,obj.ExcelTab);
        end 
       function obj = PDExcelStruct(dts)
               obj.ExcelTab = dts;               
               numOfCols = size(dts,2);
               id = 0;
               for k = 1:numOfCols   
                   if(ischar(dts{1,k}))%~any(isnan(dts{1,k})) && ~isempty(dts(1,k)))
                       id = id +1;
                       obj.AllProps{id} = dts{1,k};
                       obj.addprop(dts{1,k});                                            
                       
                       try
                         obj.(dts{1,k}) = cell2mat(dts(2:end,k));
                       catch
                           obj.(dts{1,k}) = dts(2:end,k);
                       end
                       if(strcmp(dts(1,k),'ID') || strcmp(dts(1,k),'fID'))
                           obj.(dts{1,k}) = cellfun(@num2str, dts(2:end,k), 'UniformOutput', false);
                       end
                   end
               end
        end
    end
    
    
   
end

