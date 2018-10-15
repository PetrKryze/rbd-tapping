classdef PDEval < hgsetget
    %of this class goes here
    %   Detailed explanation goes here
    
    properties
        ExData
        BKAN_L1
        BKAN_L2
        BKAN_R1
        BKAN_R2
    end
    
    
    methods
        function obj = PDEval(data)
            if(~isa(data,'PDExcelStruct'))
                error('Data nejsou typu PDExcelStruct');
            end
            obj.ExData = data;                    
        end
        function obj = LoadBKAN(obj)
            obj.BKAN_L1 = cell([length(obj.ExData.fID),1 ]);
            obj.BKAN_L2 = cell([length(obj.ExData.fID),1 ]);

            obj.BKAN_R1 = cell([length(obj.ExData.fID),1 ]);
            obj.BKAN_R2 = cell([length(obj.ExData.fID),1 ]);
            
            for k = 1:length(obj.ExData.fID)
             
                id = obj.ExData.fID{k};
                if(isnumeric(obj.ExData.fID{k}))
                    id = num2str(obj.ExData.fID{k});
                end
    
                M1 = strcat(id,'_L1','.dat');
                M2 = strcat(id,'_L2','.dat');
                M3 = strcat(id,'_P1','.dat');
                M4 = strcat(id,'_P2','.dat');                
                try
                    obj.BKAN_L1{k} = PDDataProp.InitProperties(PDData.Load(M1),15);
                catch str
                    warning(strcat(M1,':',str.message));
                end
                try
                    obj.BKAN_L2{k} = PDDataProp.InitProperties(PDData.Load(M2),15);
                   catch str
                    warning(strcat(M2,':',str.message));
                end
                try
                    obj.BKAN_R1{k} = PDDataProp.InitProperties(PDData.Load(M3),15);
                catch str
                    warning(strcat(M3,':',str.message));
                end
                try
                    obj.BKAN_R2{k} = PDDataProp.InitProperties(PDData.Load(M4),15);
                catch str
                    warning(strcat(M4,':',str.message));
                end
                
                
            end
        end
        function D = GetPOFF(obj,DT)
            D = DT(obj.ExData.Type == 2,:);
        end
        function D = GetPON(obj,DT)
            D = DT(obj.ExData.Type == 1,:);
        end
        function D = GetN(obj,DT)
            D = DT(obj.ExData.Type == 0,:);
        end
        
        function D = GetParam(obj,Param)
           D= obj.ExData.(Param); 
        end
        
        function D = GetBrParam(obj,Param)
            
            for k = 1: length(obj.BKAN_L1)
                  D(k,1) = obj.BKAN_L1{k}.(Param); 
                  D(k,2) = obj.BKAN_L2{k}.(Param); 
                  D(k,3) = obj.BKAN_R1{k}.(Param); 
                  D(k,4) = obj.BKAN_R2{k}.(Param); 
            end
        end
        function D = GetBrWorseHandAvg(obj,Param)
            DT = obj.GetBrParamAvg(Param);
            D = obj.GetWorseCol(DT);
        end
        
        
        
        function D = GetBrParamAvg(obj,Param)
            B = obj.GetBrParam(Param);
            D(:,1) = (B(:,1) + B(:,2))/2;
            D(:,2) = (B(:,3) + B(:,4))/2;            
        end
        function DOUT = GetWorseCol(obj,D)            
            DOUT = D(:,1).*(obj.ExData.WHAND == 'L')+D(:,2).*(obj.ExData.WHAND == 'R');            
        end
        %{
        function [P,N] = DivideData()
            
            
            
        end
        %}
    end
    
end

