classdef XeStreamlinePol < handle
    %This class will take Rubidium Polarization data someone as yet to be
    %determined.
    
    %Note: This model does not account for any heat tranfer or chemical
    %transport effects. It only will use flow data from Elmer to ESTIMATE
    %the Xenon polarization. 
    
    %Note!!!!: This class will only calculate polarization information for
    %a single stream line. You will need another class to create multiple
    %instances of this class to calculate multiple streamlines.
    
    %The scheme is pretty straight forward. Elmer (using Paraview
    %Visualization) can give me stream lines. 
    
    %We will use two Master Equations:
    %K(n) = Pxe(n) - Prb(n)*g/(G+g)
    %Pxe(n+1) = K(n)*exp(-(G+g)*dt)+Prb(n)*g/(G+g)
    %This ought to do it!!!
    
    properties
        Pxeline; %an n dim array containing calculated polarizations at each time point.
    end
    %
    properties(Access=private)
        n; %number of time points
        t; %an n dimensional array containing the time points. These are read in from the Paraview export file
        g;%an n dim array containing calculated spin-exchange rates at each time point
        G; %an n dim array containing calculated spin-destruction rates at each time point
        K; %an n dim array containing calculated co-factors at each time point
        dt; % t(n+1)-t(n)
        Prb;% the rubidium polarization from some class
    end
    %
    properties(Access = private)
        Streamline % A streamline to do the calculation on
    end
    
    methods
     %  
    
        function out = get.Pxeline(obj)
            out = zeros(1,obj.n); %Initialize the Xenon polarization array
            
            %%% Read in the object variables%%%%%%
            K = obj.K;                           %
            Prb = obj.Prb;                       % 
            G = obj.G;                           %
            g = obj.g;                           %
            dt = obj.dt;                         %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            for i = 1:obj.n-1
                dout(i) = g(i)*(Prb(i)-out(i))-G(i)*out(i);
                out(i+1) = out(i)+dt(i)*dout(i);
                %display(dout(i));
                %display(out(i+1));
                %display(dt(i));
            end
            
        end
        
        function obj = XeStreamlinePol(Streamline,Prb,g,G)
            obj.Streamline = Streamline; %Get the streamline
            obj.Prb = Prb; %Get the rub polarization
            obj.G = G;
            obj.g = g;
            obj.n = length(Streamline.Zcoord);
            obj.dt = Streamline.DiffTime;
        end
        
        
    %
    %
    end
    
    
end

