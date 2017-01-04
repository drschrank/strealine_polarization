%Works Local
i=1;
%v = 2.84e-4; %0,1SLM
v=0.0048; %1,7SLM
Points2 = -10;
while max(Points2)<0.06
    SeedIds(i) = 0;
    IntegratedTime(i) = 0.1*i-0.1;
    Points0(i) = 0;
    Points1(i) = 0;
    Points2(i) = -0.06+v*IntegratedTime(i);
    i = i+1;
end
IntegrationTime = IntegratedTime';
Points0 = Points0';
Points1 = Points1';
Points2 = Points2';
SeedIds = SeedIds';
PlugFlow = table(IntegrationTime,Points0,Points1,Points2,SeedIds);
writetable(PlugFlow,'/Users/drschrank/Documents/MATLAB/Xenon Polarizer Model/StreamlinesCells/PlugFlow1,7SLM.csv');