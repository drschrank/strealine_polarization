function [LaserProfile,OpticalPumpingRate] = LaserPropogation(LaserInitialProfile,AbsorptionProfile,Density,AxialPositions,TotalSpinDestructionRate)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nu = LaserInitialProfile.Nu; %The initial laser profile in frequency space
Sigma = AbsorptionProfile;  %The asorption profile also in frequency space

Z = AxialPositions;         %The z points along which the function
%will be calculated units are cm! 
rb = Density;               %Density of the Rubidium in particles/cm^3
gsd = TotalSpinDestructionRate; %Total Spin Destruction Rate in Hz.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Psi = zeros(length(Nu),length(Z));            %Initialize The solution array to the correct length
Psi(:,1) = LaserInitialProfile.LaserProfile;  %The first element of the array has to be the initial laser profile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%Initialize some variable for the loop.%%%%%%%%%%%%%%%%%%%
Opt(1:length(Z)) = 0; %optical pumping rate initialization in Hz.
lambda = zeros(length(Sigma),length(Z));%This is the absorption length, or rather, it will be. Right now I'm just initializing it to the right size.
diffZ = -diff(Z); %This will probably go away eventually. It is the spacing of the z coord for the runge-kutta method. I'm not quite sure why I need a negative sign to get it to work right
s = zeros(length(Nu),length(Z)); %This matrix will be used in the diff equation solution. Just initializing it.

for i = 1:length(Z)-1
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Opt(i) = trapz(Nu,Psi(:,i).*Sigma(:));
    %Opt(i) = SolverSimpson(Psi(:,i).*Sigma(:),Nu).int;%optical pumping rate calculate int(Psi*Sigma,dnu)
    %%%%%%%%%%Check to make sure the optical pumping rate is greater than
    %%%%%%%%%%zero (it has to be). If it's not, make it zero. This prevent
    %%%%%%%%%%oscilation of the solution for very low optical pumping
    %%%%%%%%%%rates.
    if Opt(i) < 0
        Opt(i) = 0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Here I actually calculate lambda, the aforementioned absorption
    %length. Everything is this equation is a scalar with the exception of
    %Sigma. Remember that lambda is different for different frequencies
    %(the first index).
    lambda(:,i) =  Sigma(:)*rb(i)*gsd(i)/(Opt(i)+gsd(i));
    %Check to make sure all the lambdas are greater than zero. If not, make
    %them zero. This is important to keep the solution from oscilating. 
    lambda(lambda < 0) = 0;
    
    %Let's try the above code for the momement. I think it might be faster.
    %{
    for j = 1:length(Sigma)
        
        if lambda(j,i)<0
            
            lambda(j,i) = 0;
            
        end
    end
    %}
    
    
    %H = (B - A) / length(Z);
    %Try Euler's Method
    
    
    %%%%Setup the Runge-Kutta Solution Spacing
    H = diffZ(i);
    h24 = H / 24;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Euler Start Here
    Psi(:,i+1) = Psi(:,i) +(-lambda(:,i).*Psi(:,i))*H;
    %Enforce monotonically decreasing function
        if any(Psi(:,i+1)> Psi(:,i))%round about way of checking if any element of Psi(i+1) are larger than Psi(i)
            Psi(:,i+1) = Psi(:,i);
        end
    %Euler End Here
    
    %{
    F = @(Z,Psi) -lambda(:,i).*Psi;
    
    
    p = min(3,length(Z));
    s(:,i) = F(Z(i), Psi(:,i));
    
    if i <= p % start-up phase, using Runge-Kutta of order 4
        
        s2 = F(Z(i) + H / 2, Psi(:,i) + s(:,i) * H /2);
        s3 = F(Z(i) + H / 2, Psi(:,i) + s2 * H /2);
        s4 = F(Z(i+1), Psi(:,i) + s3 * H);
        Psi(:,i+1) = Psi(:,i) + (s(:,i) + s2+s2 + s3+s3 + s4) * H / 6;
        %Enforce monotonically decreasing function
        if any(Psi(:,i+1)> Psi(:,i))%round about way of checking if any element of Psi(i+1) are larger than Psi(i)
            Psi(:,i+1) = Psi(:,i);
        end
        
    end;
    
    if i > p
        
        % main phase
        Psi(:,i+1) = Psi(:,i) + (55 * s(:,i) - 59 * s(:,i-1) + 37 * s(:,i-2) - 9 * s(:,i-3)) * h24; % predictor
        Psi(:,i+1) = Psi(:,i) + (9 * F(Z(i+1), Psi(:,i+1)) + 19 * s(:,i) - 5 * s(:,i-1) + s(:,i-2)) * h24; % corrector
        
        %Enforce monotonically decreasing function
        if any(Psi(:,i+1)> Psi(:,i))%round about way of checking if any element of Psi(i+1) are larger than Psi(i)
            Psi(:,i+1) = Psi(:,i);
        end
        
        
    end;
    %}
    %Check if the program screwed up and let psi be
    %negative at some point. If it did, set Psi to 0.
    for j = 1:length(Sigma)
        
        if Psi(j,i+1)<0
            
            Psi(j,i+1) = 0;
            
        end
    end
    %surf(Z,Nu,Psi)
end

LaserProfile = Psi;
OpticalPumpingRate = Opt;



end

