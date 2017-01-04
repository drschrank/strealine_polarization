%Works Local v2.1
classdef Polarizer < handle
    %This class is an entire polarizer. It calculates all the relevent SEOP
    %parameters for a given polarizer state.
    
    properties(Constant = true)
        
        Pressure = 6;%atm
        HeliumRatio = .89 ;
        NitrogenRatio =.1;
        XenonRatio = .01;
        WallRelaxationRate = .0004;%Hz
        
        LaserPower = 60; %Watts
        CenterWaveLength = 794.7; %nm
        SpecturalWidth = .5; %nm
        SpectralDivision = 501;%Must be odd
        BeamRadius = 5/2; %In cm
        
        XOutlet = 1e3;%meter
        YOutlet = 0.025;%meter
        ZOutlet = 1e3;%meter
        TimeMax = 600;%Seconds
        DiffTimeMax = 1;%Seconds
        
    end
    properties
        Temperature
    end
    properties
        cell
        laser
        He
        N2
        Xe
        Rb
        Streamlines
    end
    
    properties
        XePolOut
        Transmission
        ProductionRate
        
    end
    
    properties (Access = private)
        LaserProfileGridPrivate
        XenonPolStreamNum
    end
    
    methods
        function obj = Polarizer(StreamlineFileName,CellFileName, Temperature)
            obj.Temperature = Temperature;
            HeliumDensity = obj.HeliumRatio*obj.Pressure;
            NitrogenDensity = obj.NitrogenRatio*obj.Pressure;
            XenonDensity = obj.XenonRatio*obj.Pressure;
            
            Data = StreamlineReader(StreamlineFileName);
            Streamlines = Streamline(Data);
            cell = Cell(CellFileName);
            laser = Laser(obj.LaserPower,obj.BeamRadius,obj.CenterWaveLength,obj.SpecturalWidth,obj.SpectralDivision);
            He = Helium(cell,HeliumDensity,obj.Temperature);
            N2 = Nitrogen(cell,NitrogenDensity,obj.Temperature);
            Xeint = Xenon(cell,XenonDensity,obj.Temperature,obj.WallRelaxationRate,He,N2,[]);
            
            %Needs to be commented out of plug flow
            %{
            if (numel(Streamlines) >1)
                Exclude = StreamlineSorter(-1e3,-1e3,-1e3,600,60,Streamlines);
                exclude = flip(Exclude.ExcludedStreamlines);
                for i = 1:length(exclude)
                    Streamlines(exclude(i)) = [];
                end
                Streamlines(numel(Streamlines)) = [];
            end
            %}
            
            %Calculate Rubidium parameters
            obj.Rb = Rubidium(cell, laser,obj.Temperature,He,N2,Xeint);
            
            %Calcualte Xenon Parameters given Rb parameters
            obj.Xe = Xenon(cell,XenonDensity,obj.Temperature,obj.WallRelaxationRate,He,N2,obj.Rb);
            
            
            
            obj.cell = cell;
            obj.Streamlines = Streamlines;
            obj.laser = laser;
            obj.He = He;
            obj.N2 = N2;
            obj.LaserProfileGridPrivate = obj.LaserProfileGrid();
            obj.RubidiumPolarization();
            obj.XePolOut = obj.XenonOutputPolarization();
            
        end
        
        function Intensity = LaserProfileGrid(obj)
            
            zspan = [obj.cell.MaxZ*100,obj.cell.MinZ*100];%Multiply by 100 to change meter to cm
            
            InitialProfile = transpose(obj.laser.InitialProfile.LaserProfile);
            
            [ZArray,LaserIntensityArray] = ode45(@obj.dLaserIntensity,zspan,InitialProfile);
            
            Intensity = struct('Zcoords',ZArray./100,...%Divide by 100 to get back to meters
                'Intensity',LaserIntensityArray,'Nu',obj.laser.InitialProfile.Nu);
            
            
            
        end
        
        
        function  Intensity = LaserIntensity(obj,x,y,z)
            %Confine beam to active region of the cell by only doing
            %intensity calcuation in active region. If outside of this
            %region, the beam intensity will be zero. Assume the beam is
            %centered around x= 0 y=0.
            
            beamradius = obj.BeamRadius*.01;%multiply by .01 to change from cm to m
            %Find the inactive region is the tranjectory.
            inactiveregioncoords = (x.^2+y.^2>=beamradius^2);
            
            
            Int = obj.LaserProfileGridPrivate.Intensity;
            Nu = obj.LaserProfileGridPrivate.Nu;
            %Try vectorizing the operation to increase speed
            Zcoords = obj.LaserProfileGridPrivate.Zcoords;
            
            [Z,nu] = meshgrid(Zcoords,Nu);
            Intensity = interp2(Z,nu,Int',z,Nu);
            
            
            
            Intensity(:,inactiveregioncoords) = 0;
            
            
            
            %Tryin speeding this up with arrayfun
            %{
            i = 1:length(obj.laser.InitialProfile.Nu);
            
            Intensityfun =@(i)  interp1(Zcoords,Int(:,i),z);
            
            Intensity = arrayfun(Intensityfun,i);
            %}
        end
        
        function out = get.Transmission(obj)
            
            nu = obj.LaserProfileGridPrivate.Nu;
            psiint = obj.LaserProfileGridPrivate.Intensity(1,:);
            psifin = obj.LaserProfileGridPrivate.Intensity(end,:);
            
            InitialIntensity = trapz(nu,psiint);
            
            FinalIntensity = trapz(nu,psifin);
            
            out = FinalIntensity/InitialIntensity;
        end
        
        function opti = OpticalPumpingRate(obj,x,y,z)
            nu = obj.laser.InitialProfile.Nu;
            sigma = obj.Rb.AbsorptionProfile(x,y,z);
            
            psi = obj.LaserIntensity(x,y,z);
            
            opti = trapz(nu,psi.*sigma');
            
        end
        
        function RbPolAve = RubidiumPolarization(obj)
            
            %Trying to speed this up using arrayfun. Write the function to
            %calc RbPol in a turse manner.
            %Optifun = @(x,y,z) obj.OpticalPumpingRate(x,y,z);
            %GSDfun = @(x,y,z) obj.Rb.TotalSpinDestructionRate(x,y,z);
            
            RbPolAveLine(1:numel(obj.Streamlines)) = 0;
            
            for i = 1:numel(obj.Streamlines)
                
                x = obj.Streamlines(i).Xcoord;
                y = obj.Streamlines(i).Ycoord;
                z = obj.Streamlines(i).Zcoord;
                
                Opti = obj.OpticalPumpingRate(x,y,z);
                GSD = obj.Rb.TotalSpinDestructionRate(x,y,z);
                
                RbPol = Opti'./(GSD+Opti');
                
                obj.Streamlines(i).RubidiumPolarization = RbPol;
                RbPolAveLine(i) = mean(RbPol);
                disp(i/numel(obj.Streamlines))
            end
            RbPolAve = mean(RbPolAveLine);
        end
        
        %The new and improved XenonOutputPolarization Function YeHaa!
        function XenPol = XenonOutputPolarization(obj)
            XePolend(1:numel(obj.Streamlines)) = 0; %Initialize XePolend
            
            for i = 1:numel(obj.Streamlines);
                
                obj.XenonPolStreamNum = i; %So that diffXePol knows which streamline we are on.
                tspan = [obj.Streamlines(i).MinTime obj.Streamlines(i).MaxTime]; %So ode45 knows the extent of time of the streamline
                [Time,XePol] = ode45(@obj.diffXePol,tspan,0);
                
                obj.Streamlines(i).XenonPolarization = arrayfun(@(t) interp1(Time,XePol,t),obj.Streamlines(i).Time);
                
                XePolend(i) = obj.Streamlines(i).XenonPolarization(end);
            end
            
            XenPol = mean(XePolend);
            
        end
        
        
        
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
    end
    
    methods (Access = private)
        function dLI = dLaserIntensity(obj,z,psi)
            nu = transpose(obj.laser.InitialProfile.Nu);
            sigma = transpose(obj.Rb.AbsorptionProfile(0,0,z));
            rb = obj.Rb.Density(0,0,z);
            gammasd = obj.Rb.TotalSpinDestructionRate(0,0,z);
            opti = trapz(nu,sigma.*psi);
            
            dLI = rb*gammasd.*sigma.*psi./(opti+gammasd);
            
        end
        
        function dPdt = diffXePol(obj,t,XePol)
            
            i = obj.XenonPolStreamNum;
            
            x = interp1(obj.Streamlines(i).Time,obj.Streamlines(i).Xcoord,t);
            y = interp1(obj.Streamlines(i).Time,obj.Streamlines(i).Ycoord,t);
            z = interp1(obj.Streamlines(i).Time,obj.Streamlines(i).Zcoord,t);
            
            Prb = interp1(obj.Streamlines(i).Time,obj.Streamlines(i).RubidiumPolarization,t);
            
            g = obj.Xe.SpinExchangeRate(x,y,z);
            G = obj.Xe.SpinRelaxationRate(x,y,z);
            
            
            
            dPdt = g*(Prb-XePol)-G*XePol;
        end
        
    end
end