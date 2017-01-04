%Works Local v2.1
classdef StreamlineSorter
    %UNTITLED This class will delete and truncate Streamline so that they
    %are an appropriate size for the cell. If a streamline does not reach
    %the outlet, it is deleted. When a streamline is truncated to the point
    %where it reaches the outlet of the cell
    
    properties
        CellOutletX
        CellOutletY
        CellOutletZ
        TimeMax
        ExcludedStreamlines
        DiffTimeMax
    end
    properties(Access = private)
        streamline
    end
    
    
    methods
        function obj = StreamlineSorter(x,y,z,t,dt,streamline)
            obj.CellOutletX = x;
            obj.CellOutletY = y;
            obj.CellOutletZ = z;
            obj.TimeMax = t;
            obj.DiffTimeMax = dt;
            obj.streamline = streamline;
        end
        %Check the streamline to see if it leaves the cell. If not, add it to the list
        function out = get.ExcludedStreamlines(obj)
            
            excludestreamlinetemp = [];
          %We will check all of the streamlines to make sure that they meet
          %the critera
            for i=1:obj.streamline(1).Total
                %Make sure the streamlines are longer than length 1 or else
                %we will have problems.
                if obj.streamline(i).Length ==1
                    excludestreamlinetemp = cat(1,excludestreamlinetemp,i);
                else
                    Xtest = obj.streamline(i).Xcoord > obj.CellOutletX;
                    Ytest = obj.streamline(i).Ycoord > obj.CellOutletY;
                    Ztest = obj.streamline(i).Zcoord > obj.CellOutletZ;
                    Ttest = obj.streamline(i).MaxTime;
                    Tmax = obj.TimeMax;
                    DTmax = obj.DiffTimeMax;
                    DTest = obj.streamline(i).MaxDiffTime;
                    DTestmin = obj.streamline(i).MinDiffTime <= 0;
                    TotalTest = sum(Xtest)+sum(Ytest)+sum(Ztest); %There should be some parts of the streamlines that are greater than XelOutletCoord; thus if we are ok, test variable should be non zero
                    
                    if ((TotalTest == 0) || (Tmax < Ttest) || (DTmax < DTest) || DTestmin)
                        excludestreamlinetemp = cat(1,excludestreamlinetemp,i);
                    end
                end
                
            end
            
            out = excludestreamlinetemp;
        end
        
        
    end
    
end