%Works Local v2.1
classdef Laser
    %This clas contains more or less all the information one will need
    %about the laser.
    properties
        Power%in Watts
        SpectralDiv; %Number of points used to descretize the laser spectrum
        CenterWaveLength; %Center of laser spectrum, usually set for 795 nm
        nu0; %Central frequency of laser spectral profile
        FWHM; %Full Width at Half Max of the Laser spectral profile in frequency space
        Area; %Assume a circular beam (although it is probably not), this is the physical area of the beam in cm^2
        Width; %FWHM of the spectural profile of the beam in nm
        InitialProfile; %Laser spectral profile in frequency space. Assume a Gaussin profile. This is before it enters the cell.
        Radius; %Radius of the beam in cm; Assumed to match the Cell
        Profile;
        
    end
    
    properties (Constant = true)
        h = 6.260766e-34 %Plank's constant
    end
    
    methods
        %
        %Constructor
        function obj = Laser(Power,Radius,CenterWaveLength,Width,SpectralDivision)
            obj.Power = Power;
            obj.Radius = Radius;
            obj.CenterWaveLength = CenterWaveLength;
            obj.Width = Width;
            obj.SpectralDiv = SpectralDivision;
            
        end
        %
        %Calculate the center of the beam in frequecy units
        function out = get.nu0(obj)
            out = 3e17/obj.CenterWaveLength;
        end
        %
        %Get the FWHM in frequency units.
        function out = get.FWHM(obj)
            out = -3e17/(obj.CenterWaveLength+obj.Width/2)+3e17/(obj.CenterWaveLength-obj.Width/2);
        end
        %
        %Hopefully this is self-explanitory
        function out = get.Area(obj)
            out = pi*obj.Radius^2;%Radius in cm^2
        end
        
        function out = get.InitialProfile(obj)
            nu0 = obj.nu0;
            FWHM = obj.FWHM;
            nu = linspace(nu0-4*FWHM,nu0+4*FWHM,obj.SpectralDiv);
            
            S = FWHM/(sqrt(8*log(2)));
            C= 2*sqrt(2*pi)*S*obj.Power/(obj.Area*obj.h)*(sqrt(2*pi)*nu0*S*(1+erf(sqrt(2)/2*nu0/S))-2*S^2*exp(-(nu0)^2/(2*S^2)))^(-1);
            
            out = struct('Nu',nu,'LaserProfile',C/(sqrt(2*pi)*S).*exp(-(nu-nu0).^2./(2*S^2)));
            
        end
        
        
        
        function dpsi = LaserAbsorbFunction(z,psi,obj)
            
            Zpoints = obj.Cell.Zpoints;
            
            sigma = obj.Rubidium.AbsorptionProfile;
            nu = obj.Nu;
            
            Rb = @(z)interp1(Zpoints,obj.Rubidium.Density,z);
            GSD = @(z)interp1(Zpoints,obj.Rubidium.TotalSpinDestruction,z);
            opticalpumpingrate = @(nu,sigma,psi) trapz(nu,sigma.*psi);
            
            lambda =  sigma.*Rb(z).*GSD(z)./(opticalpumpingrate(nu,sigma,psi)+GSD(z));
            dpsi = -lambda*psi;
            
            
        end
        
        
    end
end
