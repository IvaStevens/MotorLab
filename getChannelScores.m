function channelScores = getChannelScores(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [VARNAME2,VARNAME3,VARNAME4,VARNAME5,VARNAME6,VARNAME7,VARNAME8,VARNAME9,VARNAME10,VARNAME11,VARNAME12,VARNAME13,VARNAME14,VARNAME15,VARNAME16,VARNAME17,VARNAME18,VARNAME19,VARNAME20,VARNAME21,VARNAME22,VARNAME23,VARNAME24,VARNAME25,VARNAME26,VARNAME27,VARNAME28,VARNAME29,VARNAME30,VARNAME31,VARNAME32,VARNAME33,VARNAME34,VARNAME35,VARNAME36,VARNAME37,VARNAME38,VARNAME39,VARNAME40,VARNAME41,VARNAME42,VARNAME43,VARNAME44,VARNAME45,VARNAME46,VARNAME47,VARNAME48,VARNAME49,VARNAME50,VARNAME51,VARNAME52,VARNAME53,VARNAME54,VARNAME55,VARNAME56,VARNAME57,VARNAME58,VARNAME59,VARNAME60,VARNAME61,VARNAME62,VARNAME63,VARNAME64,VARNAME65,VARNAME66,VARNAME67,VARNAME68,VARNAME69,VARNAME70,VARNAME71,VARNAME72,VARNAME73,VARNAME74,VARNAME75,VARNAME76,VARNAME77,VARNAME78,VARNAME79,VARNAME80,VARNAME81,VARNAME82,VARNAME83,VARNAME84,VARNAME85,VARNAME86,VARNAME87,VARNAME88,VARNAME89,VARNAME90,VARNAME91,VARNAME92,VARNAME93,VARNAME94,VARNAME95,VARNAME96,VARNAME97,VARNAME98,VARNAME99,VARNAME100,VARNAME101,VARNAME102,VARNAME103,VARNAME104,VARNAME105,VARNAME106,VARNAME107,VARNAME108,VARNAME109,VARNAME110,VARNAME111,VARNAME112,VARNAME113,VARNAME114,VARNAME115,VARNAME116,VARNAME117,VARNAME118,VARNAME119,VARNAME120,VARNAME121,VARNAME122,VARNAME123,VARNAME124,VARNAME125,VARNAME126,VARNAME127,VARNAME128,VARNAME129,VARNAME130,VARNAME131,VARNAME132,VARNAME133,VARNAME134,VARNAME135,VARNAME136,VARNAME137,VARNAME138,VARNAME139,VARNAME140,VARNAME141,VARNAME142,VARNAME143,VARNAME144,VARNAME145,VARNAME146,VARNAME147,VARNAME148,VARNAME149,VARNAME150,VARNAME151,VARNAME152,VARNAME153,VARNAME154,VARNAME155,VARNAME156,VARNAME157,VARNAME158,VARNAME159,VARNAME160,VARNAME161]
%   = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   [VARNAME2,VARNAME3,VARNAME4,VARNAME5,VARNAME6,VARNAME7,VARNAME8,VARNAME9,VARNAME10,VARNAME11,VARNAME12,VARNAME13,VARNAME14,VARNAME15,VARNAME16,VARNAME17,VARNAME18,VARNAME19,VARNAME20,VARNAME21,VARNAME22,VARNAME23,VARNAME24,VARNAME25,VARNAME26,VARNAME27,VARNAME28,VARNAME29,VARNAME30,VARNAME31,VARNAME32,VARNAME33,VARNAME34,VARNAME35,VARNAME36,VARNAME37,VARNAME38,VARNAME39,VARNAME40,VARNAME41,VARNAME42,VARNAME43,VARNAME44,VARNAME45,VARNAME46,VARNAME47,VARNAME48,VARNAME49,VARNAME50,VARNAME51,VARNAME52,VARNAME53,VARNAME54,VARNAME55,VARNAME56,VARNAME57,VARNAME58,VARNAME59,VARNAME60,VARNAME61,VARNAME62,VARNAME63,VARNAME64,VARNAME65,VARNAME66,VARNAME67,VARNAME68,VARNAME69,VARNAME70,VARNAME71,VARNAME72,VARNAME73,VARNAME74,VARNAME75,VARNAME76,VARNAME77,VARNAME78,VARNAME79,VARNAME80,VARNAME81,VARNAME82,VARNAME83,VARNAME84,VARNAME85,VARNAME86,VARNAME87,VARNAME88,VARNAME89,VARNAME90,VARNAME91,VARNAME92,VARNAME93,VARNAME94,VARNAME95,VARNAME96,VARNAME97,VARNAME98,VARNAME99,VARNAME100,VARNAME101,VARNAME102,VARNAME103,VARNAME104,VARNAME105,VARNAME106,VARNAME107,VARNAME108,VARNAME109,VARNAME110,VARNAME111,VARNAME112,VARNAME113,VARNAME114,VARNAME115,VARNAME116,VARNAME117,VARNAME118,VARNAME119,VARNAME120,VARNAME121,VARNAME122,VARNAME123,VARNAME124,VARNAME125,VARNAME126,VARNAME127,VARNAME128,VARNAME129,VARNAME130,VARNAME131,VARNAME132,VARNAME133,VARNAME134,VARNAME135,VARNAME136,VARNAME137,VARNAME138,VARNAME139,VARNAME140,VARNAME141,VARNAME142,VARNAME143,VARNAME144,VARNAME145,VARNAME146,VARNAME147,VARNAME148,VARNAME149,VARNAME150,VARNAME151,VARNAME152,VARNAME153,VARNAME154,VARNAME155,VARNAME156,VARNAME157,VARNAME158,VARNAME159,VARNAME160,VARNAME161]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [VarName2,VarName3,VarName4,VarName5,VarName6,VarName7,VarName8,VarName9,VarName10,VarName11,VarName12,VarName13,VarName14,VarName15,VarName16,VarName17,VarName18,VarName19,VarName20,VarName21,VarName22,VarName23,VarName24,VarName25,VarName26,VarName27,VarName28,VarName29,VarName30,VarName31,VarName32,VarName33,VarName34,VarName35,VarName36,VarName37,VarName38,VarName39,VarName40,VarName41,VarName42,VarName43,VarName44,VarName45,VarName46,VarName47,VarName48,VarName49,VarName50,VarName51,VarName52,VarName53,VarName54,VarName55,VarName56,VarName57,VarName58,VarName59,VarName60,VarName61,VarName62,VarName63,VarName64,VarName65,VarName66,VarName67,VarName68,VarName69,VarName70,VarName71,VarName72,VarName73,VarName74,VarName75,VarName76,VarName77,VarName78,VarName79,VarName80,VarName81,VarName82,VarName83,VarName84,VarName85,VarName86,VarName87,VarName88,VarName89,VarName90,VarName91,VarName92,VarName93,VarName94,VarName95,VarName96,VarName97,VarName98,VarName99,VarName100,VarName101,VarName102,VarName103,VarName104,VarName105,VarName106,VarName107,VarName108,VarName109,VarName110,VarName111,VarName112,VarName113,VarName114,VarName115,VarName116,VarName117,VarName118,VarName119,VarName120,VarName121,VarName122,VarName123,VarName124,VarName125,VarName126,VarName127,VarName128,VarName129,VarName130,VarName131,VarName132,VarName133,VarName134,VarName135,VarName136,VarName137,VarName138,VarName139,VarName140,VarName141,VarName142,VarName143,VarName144,VarName145,VarName146,VarName147,VarName148,VarName149,VarName150,VarName151,VarName152,VarName153,VarName154,VarName155,VarName156,VarName157,VarName158,VarName159,VarName160,VarName161] = importfile('Ivan_Channels.csv',2, 36);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2017/03/20 16:52:06

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
VarName2 = cell2mat(raw(:, 1));
VarName3 = cell2mat(raw(:, 2));
VarName4 = cell2mat(raw(:, 3));
VarName5 = cell2mat(raw(:, 4));
VarName6 = cell2mat(raw(:, 5));
VarName7 = cell2mat(raw(:, 6));
VarName8 = cell2mat(raw(:, 7));
VarName9 = cell2mat(raw(:, 8));
VarName10 = cell2mat(raw(:, 9));
VarName11 = cell2mat(raw(:, 10));
VarName12 = cell2mat(raw(:, 11));
VarName13 = cell2mat(raw(:, 12));
VarName14 = cell2mat(raw(:, 13));
VarName15 = cell2mat(raw(:, 14));
VarName16 = cell2mat(raw(:, 15));
VarName17 = cell2mat(raw(:, 16));
VarName18 = cell2mat(raw(:, 17));
VarName19 = cell2mat(raw(:, 18));
VarName20 = cell2mat(raw(:, 19));
VarName21 = cell2mat(raw(:, 20));
VarName22 = cell2mat(raw(:, 21));
VarName23 = cell2mat(raw(:, 22));
VarName24 = cell2mat(raw(:, 23));
VarName25 = cell2mat(raw(:, 24));
VarName26 = cell2mat(raw(:, 25));
VarName27 = cell2mat(raw(:, 26));
VarName28 = cell2mat(raw(:, 27));
VarName29 = cell2mat(raw(:, 28));
VarName30 = cell2mat(raw(:, 29));
VarName31 = cell2mat(raw(:, 30));
VarName32 = cell2mat(raw(:, 31));
VarName33 = cell2mat(raw(:, 32));
VarName34 = cell2mat(raw(:, 33));
VarName35 = cell2mat(raw(:, 34));
VarName36 = cell2mat(raw(:, 35));
VarName37 = cell2mat(raw(:, 36));
VarName38 = cell2mat(raw(:, 37));
VarName39 = cell2mat(raw(:, 38));
VarName40 = cell2mat(raw(:, 39));
VarName41 = cell2mat(raw(:, 40));
VarName42 = cell2mat(raw(:, 41));
VarName43 = cell2mat(raw(:, 42));
VarName44 = cell2mat(raw(:, 43));
VarName45 = cell2mat(raw(:, 44));
VarName46 = cell2mat(raw(:, 45));
VarName47 = cell2mat(raw(:, 46));
VarName48 = cell2mat(raw(:, 47));
VarName49 = cell2mat(raw(:, 48));
VarName50 = cell2mat(raw(:, 49));
VarName51 = cell2mat(raw(:, 50));
VarName52 = cell2mat(raw(:, 51));
VarName53 = cell2mat(raw(:, 52));
VarName54 = cell2mat(raw(:, 53));
VarName55 = cell2mat(raw(:, 54));
VarName56 = cell2mat(raw(:, 55));
VarName57 = cell2mat(raw(:, 56));
VarName58 = cell2mat(raw(:, 57));
VarName59 = cell2mat(raw(:, 58));
VarName60 = cell2mat(raw(:, 59));
VarName61 = cell2mat(raw(:, 60));
VarName62 = cell2mat(raw(:, 61));
VarName63 = cell2mat(raw(:, 62));
VarName64 = cell2mat(raw(:, 63));
VarName65 = cell2mat(raw(:, 64));
VarName66 = cell2mat(raw(:, 65));
VarName67 = cell2mat(raw(:, 66));
VarName68 = cell2mat(raw(:, 67));
VarName69 = cell2mat(raw(:, 68));
VarName70 = cell2mat(raw(:, 69));
VarName71 = cell2mat(raw(:, 70));
VarName72 = cell2mat(raw(:, 71));
VarName73 = cell2mat(raw(:, 72));
VarName74 = cell2mat(raw(:, 73));
VarName75 = cell2mat(raw(:, 74));
VarName76 = cell2mat(raw(:, 75));
VarName77 = cell2mat(raw(:, 76));
VarName78 = cell2mat(raw(:, 77));
VarName79 = cell2mat(raw(:, 78));
VarName80 = cell2mat(raw(:, 79));
VarName81 = cell2mat(raw(:, 80));
VarName82 = cell2mat(raw(:, 81));
VarName83 = cell2mat(raw(:, 82));
VarName84 = cell2mat(raw(:, 83));
VarName85 = cell2mat(raw(:, 84));
VarName86 = cell2mat(raw(:, 85));
VarName87 = cell2mat(raw(:, 86));
VarName88 = cell2mat(raw(:, 87));
VarName89 = cell2mat(raw(:, 88));
VarName90 = cell2mat(raw(:, 89));
VarName91 = cell2mat(raw(:, 90));
VarName92 = cell2mat(raw(:, 91));
VarName93 = cell2mat(raw(:, 92));
VarName94 = cell2mat(raw(:, 93));
VarName95 = cell2mat(raw(:, 94));
VarName96 = cell2mat(raw(:, 95));
VarName97 = cell2mat(raw(:, 96));
VarName98 = cell2mat(raw(:, 97));
VarName99 = cell2mat(raw(:, 98));
VarName100 = cell2mat(raw(:, 99));
VarName101 = cell2mat(raw(:, 100));
VarName102 = cell2mat(raw(:, 101));
VarName103 = cell2mat(raw(:, 102));
VarName104 = cell2mat(raw(:, 103));
VarName105 = cell2mat(raw(:, 104));
VarName106 = cell2mat(raw(:, 105));
VarName107 = cell2mat(raw(:, 106));
VarName108 = cell2mat(raw(:, 107));
VarName109 = cell2mat(raw(:, 108));
VarName110 = cell2mat(raw(:, 109));
VarName111 = cell2mat(raw(:, 110));
VarName112 = cell2mat(raw(:, 111));
VarName113 = cell2mat(raw(:, 112));
VarName114 = cell2mat(raw(:, 113));
VarName115 = cell2mat(raw(:, 114));
VarName116 = cell2mat(raw(:, 115));
VarName117 = cell2mat(raw(:, 116));
VarName118 = cell2mat(raw(:, 117));
VarName119 = cell2mat(raw(:, 118));
VarName120 = cell2mat(raw(:, 119));
VarName121 = cell2mat(raw(:, 120));
VarName122 = cell2mat(raw(:, 121));
VarName123 = cell2mat(raw(:, 122));
VarName124 = cell2mat(raw(:, 123));
VarName125 = cell2mat(raw(:, 124));
VarName126 = cell2mat(raw(:, 125));
VarName127 = cell2mat(raw(:, 126));
VarName128 = cell2mat(raw(:, 127));
VarName129 = cell2mat(raw(:, 128));
VarName130 = cell2mat(raw(:, 129));
VarName131 = cell2mat(raw(:, 130));
VarName132 = cell2mat(raw(:, 131));
VarName133 = cell2mat(raw(:, 132));
VarName134 = cell2mat(raw(:, 133));
VarName135 = cell2mat(raw(:, 134));
VarName136 = cell2mat(raw(:, 135));
VarName137 = cell2mat(raw(:, 136));
VarName138 = cell2mat(raw(:, 137));
VarName139 = cell2mat(raw(:, 138));
VarName140 = cell2mat(raw(:, 139));
VarName141 = cell2mat(raw(:, 140));
VarName142 = cell2mat(raw(:, 141));
VarName143 = cell2mat(raw(:, 142));
VarName144 = cell2mat(raw(:, 143));
VarName145 = cell2mat(raw(:, 144));
VarName146 = cell2mat(raw(:, 145));
VarName147 = cell2mat(raw(:, 146));
VarName148 = cell2mat(raw(:, 147));
VarName149 = cell2mat(raw(:, 148));
VarName150 = cell2mat(raw(:, 149));
VarName151 = cell2mat(raw(:, 150));
VarName152 = cell2mat(raw(:, 151));
VarName153 = cell2mat(raw(:, 152));
VarName154 = cell2mat(raw(:, 153));
VarName155 = cell2mat(raw(:, 154));
VarName156 = cell2mat(raw(:, 155));
VarName157 = cell2mat(raw(:, 156));
VarName158 = cell2mat(raw(:, 157));
VarName159 = cell2mat(raw(:, 158));
VarName160 = cell2mat(raw(:, 159));
VarName161 = cell2mat(raw(:, 160));

channelScores = [VarName2,VarName3,VarName4,VarName5,VarName6,VarName7,VarName8,VarName9,VarName10,VarName11,VarName12,VarName13,VarName14,VarName15,VarName16,VarName17,VarName18,VarName19,VarName20,VarName21,VarName22,VarName23,VarName24,VarName25,VarName26,VarName27,VarName28,VarName29,VarName30,VarName31,VarName32,VarName33,VarName34,VarName35,VarName36,VarName37,VarName38,VarName39,VarName40,VarName41,VarName42,VarName43,VarName44,VarName45,VarName46,VarName47,VarName48,VarName49,VarName50,VarName51,VarName52,VarName53,VarName54,VarName55,VarName56,VarName57,VarName58,VarName59,VarName60,VarName61,VarName62,VarName63,VarName64,VarName65,VarName66,VarName67,VarName68,VarName69,VarName70,VarName71,VarName72,VarName73,VarName74,VarName75,VarName76,VarName77,VarName78,VarName79,VarName80,VarName81,VarName82,VarName83,VarName84,VarName85,VarName86,VarName87,VarName88,VarName89,VarName90,VarName91,VarName92,VarName93,VarName94,VarName95,VarName96,VarName97,VarName98,VarName99,VarName100,VarName101,VarName102,VarName103,VarName104,VarName105,VarName106,VarName107,VarName108,VarName109,VarName110,VarName111,VarName112,VarName113,VarName114,VarName115,VarName116,VarName117,VarName118,VarName119,VarName120,VarName121,VarName122,VarName123,VarName124,VarName125,VarName126,VarName127,VarName128,VarName129,VarName130,VarName131,VarName132,VarName133,VarName134,VarName135,VarName136,VarName137,VarName138,VarName139,VarName140,VarName141,VarName142,VarName143,VarName144,VarName145,VarName146,VarName147,VarName148,VarName149,VarName150,VarName151,VarName152,VarName153,VarName154,VarName155,VarName156,VarName157,VarName158,VarName159,VarName160,VarName161];