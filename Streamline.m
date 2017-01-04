%Works Local v2.1
classdef Streamline < handle
    %UNTITLED4 This class is this information related to an individual
    %streamline
    
    properties
        Number;%To order the streamlines
        Time;
        Xcoord;
        Ycoord;
        Zcoord;
        Total;
        MaxTime;
        MaxXcoord;
        MaxYcoord;
        MaxZcoord;
        DiffTime;
        MaxDiffTime;
        MinTime;
        RubidiumPolarization;
        XenonPolarization;
        OpticalPumpingRate;
        Length;
        StreamlineID
        
    end
    
    methods
        function obj = Streamline(Reader)
         
            if nargin ~=0;
                obj(Reader.numberofstreamlines) = Streamline;
                
                Data = Reader.SortedImportData;
                streamlineindex = Reader.StreamLinesParse.StreamlineIndex;
                total = Reader.numberofstreamlines;
                inttimecol = Reader.IntegrationTimeColumn;
                xcol = Reader.XColumn;
                ycol = Reader.YColumn;
                zcol = Reader.ZColumn;
                streamlineidcol = Reader.StreamlineIDColumn;
                
                for i=1:total
                    obj(i).Number = i;
                    
                    obj(i).StreamlineID = Data(streamlineindex == i,streamlineidcol);
                    
                    if ~(diff(obj(i).StreamlineID) == 0) %Check to make sure all the elements of the
                                                       %streamline have the
                                                       %same IDs
                        
                        error('Error in Streamline. \nStreamlineIDs inconsistent \n Problem with streamline %s', i);
                            
                    end
                    
                    
                    obj(i).Time = Data(streamlineindex == i,inttimecol);
                    obj(i).MaxTime = max(obj(i).Time);
                    obj(i).MinTime = min(obj(i).Time);
                    
                    obj(i).DiffTime = diff(obj(i).Time);
                    obj(i).MaxDiffTime = max(obj(i).DiffTime);
                    
                    
                    obj(i).Xcoord = Data(streamlineindex == i,xcol);
                    obj(i).MaxXcoord = max(obj(i).Xcoord);
                    obj(i).Ycoord = Data(streamlineindex == i,ycol);
                    obj(i).MaxYcoord = max(obj(i).Ycoord);
                    obj(i).Zcoord = Data(streamlineindex == i,zcol);
                    obj(i).MaxZcoord = max(obj(i).Zcoord);
                    obj(i).Total = total;
                    
                    obj(i).Length = length(obj(i).Zcoord);
                    
                    %We want to find and remove any bad time points i.e.
                    %points that have repeat times
                    
                    if ~(isempty(find(obj(i).DiffTime <= 0,1)))
                        deletelines = find(obj(i).DiffTime <= 0);
                   
                            obj(i).Time(deletelines) = [];
                            
                            obj(i).Xcoord(deletelines) = []; 
                            obj(i).Ycoord(deletelines) = []; 
                            obj(i).Zcoord(deletelines) = []; 
                            
                    
                        
                        obj(i).DiffTime = diff(obj(i).Time);
                        obj(i).Length = length(obj(i).Zcoord);
                    end

                end
                
            end
  
        end
    end
    
end

