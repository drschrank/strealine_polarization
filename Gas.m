%Works Local v2.1
classdef (Abstract) Gas < handle
    %Gasses in the polarizer generally have this property.
    properties
        Density
        Temperature
    end
    
    methods
        function obj = Gas(Cell,Density,Temperature)
            Den(1:length(Cell.XPoints)) = Density;
            Temp(1:length(Cell.XPoints)) = Temperature;
            obj.Density = scatteredInterpolant(Cell.XPoints,Cell.YPoints,Cell.ZPoints,Den');
            obj.Temperature = scatteredInterpolant(Cell.XPoints,Cell.YPoints,Cell.ZPoints,Temp');
        end
        
        function out = RubidiumSpinDestructionRate(obj,x,y,z)
            out = obj.RubidiumSpinDestructionCrossSection(x,y,z).*obj.Density(x,y,z);
        end
        
    end
    
end