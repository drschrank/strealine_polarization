%Works Local v2.1
classdef Rubidium
    %This class is rubidium and all it's properties.
    
    properties
        Temperature%Temperature in C
        Density% Density of the Rubidium in particles/cc
        %AbsorptionProfile %The absorption profile of the rubidium, spectral units are tied to Laser object
        %RubidiumSpinDestructionRate%Self Spin Destruction rate in Hz
        %XenonSpinDestructionRate% in Hz
        %VanDerWallRubidiumSpinDestructionRate% in Hz, technically this is due to other gasses, but it is harder to implement as an individual property for all of them
        %TotalSpinDestructionRate %The total spin destruction rate of the rubidium in Hz
        ZPoints
        %YPoints
        %XPoints
        Polarization
    end
    
    properties(Constant = true)
        RubidiumSpinDestructionCrossSection = 3.9e-14; %Rb-Rb spin destruction rate constants
    end
    properties(Access = private)
        Laser%A Laser object, all I need is a discretized spectral profile
        Helium
        Nitrogen
        Xenon
        Cell
    end
    
    properties(Access = private,Constant = true)
        AbsorptionCenter = 794.7%Center absorption wavelength in nm
        sigma0 = 4.83*10^(-13); %Absorption cross section in cm^2 of Rb
    end
    
    
    methods
        %Construct the object
        function obj = Rubidium(Cell,Laser,Temperature,Helium,Nitrogen,Xenon)
            obj.Laser = Laser;
            obj.Temperature(1:numel(Cell.ZPoints)) = Temperature;
            obj.Helium = Helium;
            obj.Nitrogen = Nitrogen;
            obj.Xenon = Xenon;
            obj.Cell = Cell;
            %Sneaky shortcut to made Rb Density while Elmer is not
            %calculating it
            
            RbDen =10.^(10.55-4132./...
                (obj.Temperature+273.15))./(1.38e-16.*(obj.Temperature+273.15));
            
            obj.Density = scatteredInterpolant(Cell.XPoints,...
                Cell.YPoints,Cell.ZPoints,RbDen');
        end
        
        function out = get.ZPoints(obj)
            out = obj.Cell.ZPoints;
        end
       
        function out = AbsorptionProfile(obj,x,y,z)
            FrequencyCenter = 3e17/obj.AbsorptionCenter;%convert nm to Hz = c*10^9/wavelength
            
            G = (18.*obj.Helium.Density(x,y,z)+17.8.*obj.Nitrogen.Density(x,y,z)...
                +18.9.*obj.Xenon.Density(x,y,z)).*10^9;%Width of the absorption is dependent on gas densities
            %Create mesh grids so that I can vectorize the operations
            
            NuVec = 4.*(obj.Laser.InitialProfile.Nu-FrequencyCenter).^2;
            GVec = G.^2;
            
            [NuMat,GMat] =meshgrid(NuVec,GVec);
            
            
            out = obj.sigma0.*GMat./(NuMat+GMat);
            
            
            %out = G.^2*obj.sigma0./(4.*(obj.Laser.InitialProfile.Nu-FrequencyCenter).^2+G.^2);
        end
        %%%%%%%%%%%Spin Destruction Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %
        function out = VanDerWallRubidiumSpinDestructionRate(obj,x,y,z)
            %%%%%%%%Calculate the fraction of the gas mixture each element
            %%%%%%%%contributes
            fractionXe = obj.Xenon.Density(x,y,z)./(obj.Helium.Density(x,y,z)+obj.Nitrogen.Density(x,y,z)+obj.Xenon.Density(x,y,z));
            fractionHe = obj.Helium.Density(x,y,z)./(obj.Helium.Density(x,y,z)+obj.Nitrogen.Density(x,y,z)+obj.Xenon.Density(x,y,z));
            fractionN2 = obj.Nitrogen.Density(x,y,z)./(obj.Helium.Density(x,y,z)+obj.Nitrogen.Density(x,y,z)+obj.Xenon.Density(x,y,z));
            %%%%%%%%%%%%%%%%%%From Ruset's Thesis%%%%%%%%%%%%%%%%%
            out = 6469./(fractionXe+1.1*fractionN2+3.2*fractionHe);
        end
        
        function out = RubidiumSpinDestructionRate(obj,x,y,z)
            out = obj.RubidiumSpinDestructionCrossSection*obj.Density(x,y,z);
        end
        
        function out = TotalSpinDestructionRate(obj,x,y,z)
            out = obj.RubidiumSpinDestructionRate(x,y,z) + obj.Nitrogen.RubidiumSpinDestructionRate(x,y,z)...
                + obj.Helium.RubidiumSpinDestructionRate(x,y,z) + obj.Xenon.RubidiumSpinDestructionRate(x,y,z)...
                + obj.VanDerWallRubidiumSpinDestructionRate(x,y,z);
        end
        
        %We need to calculate the Rubidium Polarzition at some point. Might
        %as well do it now.
        
    end
    
end

