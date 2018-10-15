classdef PDDataView < hgsetget
    %PDDATAVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties
        Data     
        ListName
        Memento
        MementoID = 0
        MemMax = 10
    end
    methods 
        function value = get.ListName(obj)
           value = obj.Data.FileName;
        end
        
    end
    
    methods
        function obj = MemFw(obj)
            if(obj.MementoID == 0)
                return
            end
            if(obj.MementoID < length(obj.Memento))
               obj.MementoID = obj.MementoID + 1;
            end
            if(obj.MementoID <= length(obj.Memento))
               dt = obj.Data;
               obj.Data = obj.Memento{obj.MementoID};
               obj.Memento{obj.MementoID} = dt;
            end
        end
        function obj = MemBack(obj)      
            if(obj.MementoID > 1)                
               obj.MementoID = obj.MementoID - 1;
            end
            if(obj.MementoID > 0)
               dt = obj.Data;
               obj.Data = obj.Memento{obj.MementoID};
               obj.Memento{obj.MementoID} = dt;
            end
        end
        function obj = MemSave(obj)
            obj.MementoID = obj.MementoID + 1;           
            if(obj.MementoID > obj.MemMax)                
               obj.MementoID = obj.MementoID - 1;
               h = obj.Memento{1};
               delete(h);
               obj.Memento = obj.Memento(2:end); 
               obj.Memento{obj.MementoID} = obj.Data.Copy();                              
            else
               obj.Memento{obj.MementoID} =  obj.Data.Copy();
            end
            todel = obj.Memento(obj.MementoID+1:end); 
            for k =1 :length(todel)
               h = todel{k};
                delete(h); 
            end
            obj.Memento = obj.Memento(1:obj.MementoID);             
        end
        function obj = ClearBadValues(obj,thr)
            obj.MemSave();
            obj.Data.ClearBadValues(thr); 
        end
        function obj = AddPoint(obj,point)                        
            obj.MemSave();
            obj.Data.AddPoint(point);            
        end
        function obj = RemovePoint(obj,point)
            obj.MemSave();
            obj.Data.RemovePoint(point);            
        end
        function obj = AddMinMax(obj,point)                        
            obj.MemSave();
            obj.Data.AddMinMax(point);            
        end
        function obj = RemoveMinMax(obj,point)
            obj.MemSave();
            obj.Data.RemoveMinMax(point);            
        end
        function obj = MedianFilter(obj,n)                     
            obj.MemSave();  
            obj.Data.MedFilt(n);           
          %obj.Data.HighFilt();
        end
        function  obj = PDDataView(DataSource)            
            obj.Data = DataSource;                        
            
        end
        function h=PlotData(obj,prop)
           if(~isempty(obj.Data.DataTime) &&~isempty(obj.Data.DataDist))
                if(exist('prop','var'))
                   h= plot(obj.Data.DataTime,obj.Data.DataDist,prop);
                else
                   h= plot(obj.Data.DataTime,obj.Data.DataDist);
                end
           end
        end
        function h = PlotMax(obj,prop)
            if(~isempty(obj.Data.DataTime) &&~isempty(obj.Data.DataDist))
                if(exist('prop','var'))
                    h = plot(obj.Data.MaxT,obj.Data.MaxV(:,2),prop);
                else
                    h = plot(obj.Data.MaxT,obj.Data.MaxV(:,2),'r*');
                end
            end            
        end
        function h= PlotMin(obj,prop)
            if(~isempty(obj.Data.DataTime) &&~isempty(obj.Data.DataDist))
                if(exist('prop','var'))
                    h=plot(obj.Data.MinT,obj.Data.MinV(:,2),prop);
                else
                    h=plot(obj.Data.MinT,obj.Data.MinV(:,2),'g*');
                end
            end            
        end
        function h=PlotDeriv(obj,prop)
             if(~isempty(obj.Data.DataTime) &&~isempty(obj.Data.DDist))
                if(exist('prop','var'))
                    h= plot(obj.Data.DataTime(),obj.Data.DDist,prop);
                else
                    h= plot(obj.Data.DataTime(),obj.Data.DDist);
                end
            end            
            
        end
        
    end
    
end

