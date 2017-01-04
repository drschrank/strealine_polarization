%Works Local v2.1
classdef Nitrogen < Gas
    %Helium Gas class
   
    methods
        
        function obj = Nitrogen(Cell,Density,Temperature)
            obj@Gas(Cell,Density,Temperature);
        end
        
        function out = RubidiumSpinDestructionCrossSection(obj,x,y,z)                                                                       %
            out = 170*(1+(obj.Temperature(x,y,z)-90)/194.3);                                                        %
        end
        
    end
    
end

