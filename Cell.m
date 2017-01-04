%Works Local v2.1
classdef Cell
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MaxX
        MaxY
        MaxZ
        MinX
        MinY
        MinZ
        XPoints
        YPoints
        ZPoints
    end
    
    
    
    methods
        function obj = Cell(filename)
            
            import = importdata(filename);
            data = import.data;
            field = import.textdata;
            
            XCol = find(ismember(field,'"Points:0"'));
            YCol = find(ismember(field,'"Points:1"'));
            ZCol = find(ismember(field,'"Points:2"'));
            
            obj.XPoints = data(:,XCol);
            obj.YPoints = data(:,YCol);
            obj.ZPoints = data(:,ZCol);
            
            obj.MaxX = max(obj.XPoints);
            obj.MinX = min(obj.XPoints);
            
            obj.MaxY= max(obj.YPoints);
            obj.MinY = min(obj.YPoints);
            
            obj.MaxZ = max(obj.ZPoints);
            obj.MinZ = min(obj.ZPoints);
        
        end
  
        
    end
    
end

