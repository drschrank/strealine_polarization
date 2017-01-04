%Works Local v2.1
classdef Xenon < Gas
    %Helium Gas class
    
    properties

        WallRelaxation
    end
    
    properties(Access = private)
        Helium
        Nitrogen
        Rubidium
    end
    
    properties(Access = private, Constant = true)
        atta85 = .2718; %isotopic concentration of Rb85
        atta87 = .7217; %isoptopic concentration of Rb87
    end
    
    methods
        
        function obj = Xenon(Cell,Density,Temperature,WallRelaxation,Helium,Nitrogen,Rubidium)
            obj@Gas(Cell,Density,Temperature);
            obj.WallRelaxation = WallRelaxation;
            obj.Helium = Helium;
            obj.Nitrogen = Nitrogen;
            obj.Rubidium = Rubidium;
        end
        
        function sigma = RubidiumSpinDestructionCrossSection(obj,x,y,z)
            sigma =  2.44e5;% sigmaXe = 2.44e5;Xe-Rb spin destruction rate constant
        end
        
        function out = GXevdW(obj,x,y,z)
            
            out = 6.72e-5*(1/(1+25*obj.Helium.Density(x,y,z)/obj.Density(x,y,z) + 1.05*obj.Nitrogen.Density(x,y,z)/obj.Density(x,y,z)));
            
        end
        
        function out = SpinRelaxationRate(obj,x,y,z)
            
            out = obj.WallRelaxation + obj.GXevdW(x,y,z);
            
        end
        
        function out = XenonSpinExchangeCrossSection(obj,x,y,z)
        
            out = 2.2e-17.*(obj.Temperature(x,y,z)+272.15).^(1/2).*(20+272.15)^(-1/2);
            
        end
        
        function out = SpinExchangeRate(obj,x,y,z)
           
            %Try Matt's Model's Method of calculating this value. I don't
            %understand his method though
            %Physical Constant
            loschmidt=2.69e19;
            %Who knows?
            gammaXeMSE=5230;
            gammaN2MSE=5700;
            gammaHeMSE=17000;
            %Van Der Waals Spin-Exchange Rate
            
            gammaVdwSE=(obj.Density(x,y,z)*loschmidt/gammaXeMSE+...
                obj.Nitrogen.Density(x,y,z)*loschmidt/gammaN2MSE+...
                obj.Helium.Density(x,y,z)*loschmidt/gammaHeMSE)^-1*...
                obj.Rubidium.Density(x,y,z);
            %{
            %Fink's expression
            gammaVdwSE = (gammaHeMSE./(obj.Helium.Density.*loschmidt)+...
                gammaXeMSE./((obj.Density.*loschmidt).*...
                (1+0.275.*obj.Nitrogen.Density./obj.Density))).*...
                obj.Rubidium.Density;
            %}
            %Binary Spin Exchange Rate
            seXe=2.2e-16;
            gammaBinSE=seXe.*obj.Rubidium.Density(x,y,z);
            
            out=gammaBinSE+gammaVdwSE;
            
            
            %Nelson's Expression
            %{
            A =  1.16e-15*(obj.Temperature(x,y,z) + 272.15).^(-3/2) .* (20 + 272.15).^(3/2);%Front coefficeint of Van der Waal spin-exchange term = to 1/2 *
            %Kappa * alpha * G0 / (Hbar * x * G1). All of these terms are
            %defined in Nelsons thesis from 2001.

            G1 = 1.92 .* ((obj.Temperature(x,y,z) + 272.15)./413).^(-6);%characterstic pressure at which we transition from the very
            %and slow molecular regime. See Nelson's thesis from 2001.
            g = obj.Helium.Density(x,y,z)+obj.Nitrogen.Density(x,y,z)+obj.Density(x,y,z); %Total Gas Density
            gasratio = G1/g; %Ratio of G1 to g
            
            Atta85Component = .648 * obj.atta85 /(1+(gasratio)^2);
            Atta87Component = .625 * obj.atta87 / (1+(2.25 * gasratio)^2);
            
            out = obj.Rubidium.Density(x,y,z)*(obj.XenonSpinExchangeCrossSection(x,y,z) + A * gasratio * (.358 + Atta85Component...
                + Atta87Component));
            %}
        end
        
    end
end



