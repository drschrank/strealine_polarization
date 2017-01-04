%Works Local v2.1
classdef StreamlineReader
    %This class reads streamlines from Paraview outputs.
    
    properties
        numberofstreamlines;
        StreamLinesParse;
        FileName;
        ImportData;
        IntegrationTimeColumn;
        XColumn;
        YColumn;
        ZColumn;
        StreamlineIDColumn;
        SortedImportData;
    end
    
    properties(Access = private)
        FieldData;
    end
    
    
    methods
        function obj = StreamlineReader(filename)
            obj.FileName = filename;
            
        end
        
        function out = get.ImportData(obj)
            import = importdata(obj.FileName);
            out = import.data;
        end
        
        function out = get.FieldData(obj)
            import = importdata(obj.FileName);
            out = import.textdata;
        end
        
        function parseinfo = get.StreamLinesParse(obj)
            streamlineidcol = obj.StreamlineIDColumn;
            [streamlineid,~,idindex] = unique(obj.SortedImportData(:,streamlineidcol));
            parseinfo = struct('StreamlineID',streamlineid,'StreamlineIndex',idindex);
            
        end
        
        function out = get.numberofstreamlines(obj)
            out = length(obj.StreamLinesParse.StreamlineID);
        end
       
        function out= get.IntegrationTimeColumn(obj)
            out = find(ismember(obj.FieldData,'"IntegrationTime"'));
        end
        
        function out = get.XColumn(obj)
            out = find(ismember(obj.FieldData,'"Points:0"'));
        end
        
         function out = get.YColumn(obj)
            out = find(ismember(obj.FieldData,'"Points:1"'));
         end
        
         function out = get.ZColumn(obj)
            out = find(ismember(obj.FieldData,'"Points:2"'));
         end
        
        function out = get.StreamlineIDColumn(obj)
            out = find(ismember(obj.FieldData,'"SeedIds"'));
        end
        
        function SortedData = get.SortedImportData(obj)
        data = obj.ImportData;
        streamlineID = obj.StreamlineIDColumn;
        time = obj.IntegrationTimeColumn;
        
        SortedData = sortrows(data,[streamlineID time]);
        
        end
    end
    
end

