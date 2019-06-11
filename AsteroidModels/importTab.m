function [vertices,faces] = importTab(filename, method, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [indicator,data] = IMPORTFILE(FILENAME) Reads data from text file FILENAME
%   for the default selection.
%
%   [indicator,data] = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from
%   rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   [indicator,data] = importfile('eros001708.tab',1, 2564);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2018/04/16 14:40:45

if nargin == 1
    method = 2;
end

if isequal(filename,'eros001708') || isequal(filename,'eros200700')
    [vertices,faces] = method1(filename);
    faces = faces+1;
elseif method == 1
    [vertices,faces] = method1(filename);
else
    [vertices,faces] = method2(filename);
end

end

function [vertices,faces] = method1(filename, startRow, endRow)

%% Initialize variables.
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: text (%s)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%1s%15f%14f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', '', 'WhiteSpace', '', 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', '', 'WhiteSpace', '', 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Remove white space around all cell columns.
dataArray{1} = strtrim(dataArray{1});

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
indicator = dataArray{:, 1};
E00 = dataArray{:, 2};
E1 = dataArray{:, 3};
E2 = dataArray{:, 4};
data = [E00,E1,E2];

%% Separate into vertices and faces
N = length(indicator);
f = (N*3-6)*2/9; % eqn on p. 37 Scheeres Orbital Motion
v = N-f;
vertices = data(1:v,:);
faces = data((v+1):end,:);

end

function [vertices,faces] = method2(filename)
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
VFnum = textscan(fileID,'%f%f',1);
Vcol = textscan(fileID,'%f%f%f%f',VFnum{1});
Fcol = textscan(fileID,'%f%f%f%f',VFnum{2});

%% Close the text file.
fclose(fileID);

%% Separate into vertices and faces
vertices = [Vcol{2} Vcol{3} Vcol{4}];
faces = [Fcol{2} Fcol{3} Fcol{4}];

end
