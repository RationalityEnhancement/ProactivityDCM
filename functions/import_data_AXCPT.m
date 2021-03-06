%% Import data from text file.
% Script for importing data from the following text file:
%
%    /Users/falk.lieder/Dropbox/Rationality Enhancement Lab/Projects/Proactivity/data/DataAXCPT.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2019/12/16 18:28:06

addpath('C:\Users\giwama\Nextcloud\Proactivity\data');

%% Initialize variables.
filename = 'Maki - DataAXCPT.csv';
delimiter = ',';
startRow = 2;

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[2,3,4,6,7,8,9,10,11,12,13]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^[-/+]*\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end


%% Split data into numeric and string columns.
rawNumericColumns = raw(:, [2,3,4,6,7,8,9,10,11,12,13]);
rawStringColumns = string(raw(:, [1,5]));


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Make sure any text containing <undefined> is properly converted to an <undefined> categorical
for catIdx = [1,2]
    idx = (rawStringColumns(:, catIdx) == "<undefined>");
    rawStringColumns(idx, catIdx) = "";
end

%% Create output variable
DataAXCPT = table;
DataAXCPT.experiment = categorical(rawStringColumns(:, 1));
DataAXCPT.load = cell2mat(rawNumericColumns(:, 1));
DataAXCPT.reward = cell2mat(rawNumericColumns(:, 2));
DataAXCPT.age = cell2mat(rawNumericColumns(:, 3));
DataAXCPT.sex = categorical(rawStringColumns(:, 2));
DataAXCPT.AccAX = cell2mat(rawNumericColumns(:, 4));
DataAXCPT.AccAY = cell2mat(rawNumericColumns(:, 5));
DataAXCPT.AccBX = cell2mat(rawNumericColumns(:, 6));
DataAXCPT.AccBY = cell2mat(rawNumericColumns(:, 7));
DataAXCPT.RTAX = cell2mat(rawNumericColumns(:, 8));
DataAXCPT.RTAY = cell2mat(rawNumericColumns(:, 9));
DataAXCPT.RTBX = cell2mat(rawNumericColumns(:, 10));
DataAXCPT.RTBY = cell2mat(rawNumericColumns(:, 11));

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp rawNumericColumns rawStringColumns R catIdx idx;

%% extract the average accuracies
cognitive_load = table2array(DataAXCPT(:,2));
load_values = unique(cognitive_load);
reward = table2array(DataAXCPT(:,3));
rewards = unique(reward);

for l=1:numel(load_values)
    %AccAX      AccAY       AccBX    AccBY
    
    in_condition = cognitive_load == load_values(l);
    
    for c = 1:4
        accuracies_no_reward(l,c)  = mean(table2array(DataAXCPT(in_condition & ~reward,5+c)));
        accuracies_with_reward(l,c)= mean(table2array(DataAXCPT(in_condition & reward,5+c)));
    end
end

%keep accuracies_no_reward accuracies_with_reward