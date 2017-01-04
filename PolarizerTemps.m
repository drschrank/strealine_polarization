function PolarizerTemps()
%Works Local v2.1

%Set folder name
myFolder = uigetdir('~/','Choose the folder where the test files reside');

if (myFolder == 0)
    errorMessage = sprintf('Error: You must choose a base folder');
    uiwait(warndlg(errorMessage));
    return;
end

%Find the files that should be loaded for the analysis. All filenames need
%to have an ending pattern of PolCalcStreamlines.csv or they will not be
%analysized
filePattern = fullfile(myFolder, '*PolCalcStreamlines.csv');
matFiles = dir(filePattern);

[NumberofFiles,~] = size(matFiles);

if NumberofFiles < 1
    errorMessage = sprintf('Error: There are no PolCalcStreamlines.csv files in this folder.\n Please choose a folder with a PolCalcStreamline file \n or rename the proper files.');
    uiwait(warndlg(errorMessage));
    return;
end

%Set Cell file
CellFile = uigetfile(myFolder,'Select Cell Geometry File');

if (CellFile == 0)
    errorMessage = sprintf('Error: Cell Geometry File');
    uiwait(warndlg(errorMessage));
    return;
end

%Get the full path of the CellFile
CellFile = fullfile(myFolder,CellFile);


%%%%%%%%%%Loop over Files%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k = 1:NumberofFiles
    %Set this rounds file name
    Filename = fullfile(myFolder, matFiles(k).name);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Setup analysis loop                              %
    P = cell(1,1);                                   %
    h = parpool(4);                                       %
    
    parfor i = 1:1                                   %
        Temp = i*5+70;                                %
        P{i} = Polarizer(Filename,CellFile,Temp);     %
    end                                               %
    delete(gcp);                                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Setup the save file
    SaveFileName = strrep(matFiles(k).name,'PolCalcStreamlines.csv','Pol');
    SavefilePattern = fullfile(myFolder,SaveFileName);
    
    save(SavefilePattern,'P','-v7.3');
end

%sendmail('geoffry.schrank@duke.edu','All Finished With Pol Analysis');
end
