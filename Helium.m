%Works Local v2.1
classdef Helium < Gas
    %Helium Gas class
   
    
    methods
        
        function obj = Helium(Cell,Density,Temperature)
            obj@Gas(Cell,Density,Temperature);
            
        end
        
        function sigma = RubidiumSpinDestructionCrossSection(obj,x,y,z)
            sigma = 24.6*(1+(obj.Temperature(x,y,z)-90)/96.4);
        end
        
    end
    
end

