%Works Local
TempState = 15;
FileName = '250ccCell60W1,7SLMMattXeSeRate145CPlug.csv';
Xcoord = [];
Ycoord = [];
Zcoord = [];
RbPol = [];
XePol = [];
for i = 1:numel(P{TempState}.Streamlines)
Xcoord = [Xcoord,P{TempState}.Streamlines(i).Xcoord'];
Ycoord = [Ycoord,P{TempState}.Streamlines(i).Ycoord'];
Zcoord = [Zcoord,P{TempState}.Streamlines(i).Zcoord'];
RbPol = [RbPol,P{TempState}.Streamlines(i).RubidiumPolarization'];
XePol = [XePol,P{TempState}.Streamlines(i).XenonPolarization];
end
StreamlinesExport = table(Xcoord',Ycoord',Zcoord',RbPol',XePol');
writetable(StreamlinesExport,FileName);