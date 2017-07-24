function scalar_struct = CatStructFields( struct_array, how_to_cat, varargin)
%
% scalar_struct = CatStructFields( struct_array, how_to_cat, ...)
%
% Take a struct array where fields are expected to have data of a uniform size and type
% and, for each field, concatenate its values across the struct array into a single matrix
% that will be assigned to the same named field in the scalar output struct. In the case
% of nested structs, concatenate the fields recursively, so that the output is always a
% scalar structs where fields that are structs are also scalar.
%
% how_to_cat - a string argument that describes how to concatenate the
% field values:
% 'vertical':    data is concatenated vertically, i.e. along the 1-st dimension
% 'horizontal':  data is concatenated horizontally, i.e. along the 2-nd dimension
%
% Optionally, from the third argument on, the function can take the
% following option strings (in any order):
% 'transpose': transpose the concatenated field values right after concatenating them
% 'merge-fields': merge fields between structs, i.e. if some of the input
%   structs are missing some of the fields, they will be filled in with empty
%   data instead of failing the concatenation.

% Process the "how_to_cat" argument
switch( how_to_cat)
    case 'vertical'
        % If 'vertical', then data is concatenated
        % vertically, i.e. along the 1-st dimension
        cat_dim = 1;
    case 'horizontal'
        % If 'horizontal', then data is concatenated
        % horizontally, i.e. along the 2-nd dimension
        cat_dim = 2;
    otherwise
        error( ['Unrecognized value "' how_to_cat '" for the how_to_cat argument']);
end

% Process the options
options = varargin;
transpose = false;
merge = false;
keep_empty_fields = false;
string_concat = false;
for i = 1 : length( options)
    o = options{i};
    switch( o)
        case 'transpose', transpose = true;
        case 'merge-fields', merge = true;
        case 'keep-empty-fields', keep_empty_fields = true;
		case 'string-concat', string_concat = true;
        otherwise, error( ['Unrecognized option "' o '"']);
    end
end

skipSpikes = false;

fields = fieldnames( struct_array);
scalar_struct = [];
for i = 1 : length( fields)
    field_name = fields{i};
    % Add trial numbers successively 
    if strcmp(field_name, 'TrialNo')
        T = 0;
        for struct_idx = 1:length(struct_array)
            struct_array(1,struct_idx).(field_name) = T + struct_array(1,struct_idx).(field_name);
            T = struct_array(1,struct_idx).(field_name)(end);
        end
    end
    try
        if (~skipSpikes && strcmp(field_name, 'Spikes'))
            S = length(struct_array);
            for s = 1:S-1
                if s == 1
                    struct_one = struct_array(s);
                end
                struct_two = struct_array(s+1);
                survival = getStableUnits([struct_one, struct_two]);
                [catFR, catTS, catWF, catChannel, catUnit] = CatSpikes(cat_dim, [struct_one, struct_two], survival);
                struct_one.Spikes.FiringRate = catFR;
                struct_one.Spikes.SpikeTS = catTS;
                struct_one.Spikes.AverageWaveform = catWF;
                struct_one.Spikes.Channel = catChannel;
                struct_one.Spikes.Unit = catUnit;
                struct_one.Spikes.ArrayNames = struct_array(1).Spikes.ArrayNames;
                struct_one.Spikes.StartStopArrayChannelNums = struct_array(1).Spikes.StartStopArrayChannelNums;
            end
            scalar_struct.Spikes = struct_one.Spikes;
            skipSpikes = true;
            continue;
        elseif (skipSpikes && strcmp(field_name, 'Spikes'))
            continue;
        else
            % First try concatenating the current level normally
            concatenated_field = cat( cat_dim, struct_array.(field_name));
            if ischar([struct_array.(field_name)]) && string_concat
                concatenated_field = {struct_array.(field_name)};
                if (cat_dim == 1)
                    concatenated_field = concatenated_field';
                end
            end
        end
    catch
        % If concatenation fails, then, if it is a dimension mismatch, give
        % information about what field the problem was with, if it is a
        % struct field mismatch, then again give information and rethrow, 
        % unless 'merge-fields' option defined, then fill in missing fields
        me = lasterror();
        switch me.identifier
            case 'MATLAB:catenate:dimensionMismatch', error( 'CatStructFields:DimensionMismatch', ['Dimension mismatch in concatenating struct field across struct array elements, field name [' field_name ']']);
            case 'MATLAB:catenate:structFieldBad'
                if( merge) % if 'merge-fields' option defined, then try again by filling in missing fields
                    concatenated_field = MergeFields( cat_dim, struct_array.(field_name));
                else % if 'merge-fields' not defined, then we cannot recover from concatenation failure
                    error( 'CatStructFields:FieldNameMismatch', ['Sub-struct field name mismatch in concatenating struct field across struct array elements, field name [' field_name ']']);
                end
            otherwise, error( me.identifier, me.message);
        end
    end
    
    % handle the 'empty matrix' case
    if isempty(concatenated_field) && keep_empty_fields
        concatenated_field = {struct_array.(field_name)};
    end
    
    % Once we have the field concatenated, then get its type, so we can
    % decide whether to just output the result or whether we have to go
    % recursive to concatenate deeper levels of the struct
    field_type = class( concatenated_field);
    switch( field_type)
        case 'struct'
            % Recursively concatenate deeper levels
            scalar_struct.(field_name) = CatStructFields( concatenated_field, how_to_cat, options{:});
        otherwise
            % Optionally transpose the concatenated field
            if( transpose)
                concatenated_field = concatenated_field';
            end
            % Stick concatenated field in the output
            scalar_struct.(field_name) = concatenated_field;
    end
end

function survival = getStableUnits(struct_array)
    S = length(struct_array);
    CHANNEL = cell(S,1);
    UNIT = cell(S,1);
    SPIKETIMES = cell(S,1);
    WMEAN = cell(S,1);
    for s = 1:S
        CHANNEL{s} = struct_array(s).Spikes.Channel;
        UNIT{s} = struct_array(s).Spikes.Unit;
        SPIKETIMES{s} = struct_array(s).Spikes.SpikeTS;
        WMEAN{s} = struct_array(s).Spikes.AverageWaveform;
    end
    [survival, ...
        ~, ...
        ~, ...
        ~, ...
        ~, ...
        ~, ...
        ~] = unitIdentification(CHANNEL, UNIT, SPIKETIMES, WMEAN);

function [catFR, catTS, catWF, catChannel, catUnit] = CatSpikes(cat_dim, struct_array, survival)
    S = length(struct_array);
    B = nan(S,1);
    for s = 1:S
        B(s) = size(struct_array(s).Spikes.FiringRate, 2); 
    end
    for s = 1:S-1
        [r_stable,c_stable] = find(survival{s});
        r_lost = find(~sum(survival{s},2));
        c_new = find(~sum(survival{s},1));
        Lost = length(r_lost);
        New = length(c_new);
        Stable = length(r_stable);
        N = Stable + Lost + New;
        
        T = B(s)*0.01;
        
        catFR = nan(N,sum(B));
        catTS = cell(N,1);
        catWF = cell(N,1);
        catChannel = nan(N,1);
        catUnit = nan(N,1);
        n = 1;
        for i = 1:Stable
            catFR(n,:) = cat(cat_dim, struct_array(s).Spikes.FiringRate(r_stable(i),:), ...
                struct_array(s+1).Spikes.FiringRate(c_stable(i),:));
            catTS{n} = cat(cat_dim, struct_array(s).Spikes.SpikeTS{r_stable(i)}, ...
                T + struct_array(s+1).Spikes.SpikeTS{c_stable(i)});
            N1 = sum(~isnan(struct_array(s).Spikes.SpikeTS{r_stable(i)}));
            N2 = sum(~isnan(struct_array(s+1).Spikes.SpikeTS{c_stable(i)}));
            catWF{n} = N1/(N1+N2)*struct_array(s).Spikes.AverageWaveform{r_stable(i)} + ...
                N2/(N1+N2)*struct_array(s+1).Spikes.AverageWaveform{c_stable(i)};
            catChannel(n) = struct_array(s).Spikes.Channel(r_stable(i));
            catUnit(n) = struct_array(s).Spikes.Unit(r_stable(i));
            n = n + 1;
        end
        fill = nan(1,B(s+1));
        for i = 1:Lost
            catFR(n,:) = cat(cat_dim, struct_array(s).Spikes.FiringRate(r_lost(i),:), fill);
            catTS{n} = struct_array(s).Spikes.SpikeTS{r_lost(i)};
            catWF{n} = struct_array(s).Spikes.AverageWaveform{r_lost(i)};
            catChannel(n) = struct_array(s).Spikes.Channel(r_lost(i));
            catUnit(n) = struct_array(s).Spikes.Unit(r_lost(i));
            n = n + 1;
        end
        fill = nan(1,B(s));
        for i = 1:New
            catFR(n,:) = cat(cat_dim, fill, struct_array(s+1).Spikes.FiringRate(c_new(i),:));
            catTS{n} = T + struct_array(s+1).Spikes.SpikeTS{c_new(i)};
            catWF{n} = struct_array(s+1).Spikes.AverageWaveform{c_new(i)};
            catChannel(n) = struct_array(s+1).Spikes.Channel(c_new(i));
            catUnit(n) = struct_array(s+1).Spikes.Unit(c_new(i));
            if (sum(catChannel == catChannel(n)) > 1)
                dupIdx = find(catChannel == catChannel(n));
                if length(unique(catUnit(dupIdx))) < length(catUnit(dupIdx))
                    catUnit(n) = max(unique(catUnit(dupIdx))) + 1;                    
                end
            end
            n = n + 1;
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Concatenates the structs in varargin into a single struct array along
% the dimension "dim" while merging the field names between the structs.
% This is intended to be used for data that has mostly the same field names
% between structs, but where some of the fields are sometimes missing.
% Field names in the output are alphabetically sorted and represent the
% total set of field names that exist across all input structs. When the
% missing fields are filled in, their values are set to empty matrix. Some
% of the input arguments are allowed to be empty matrix, in which case all
% field names are filled in from the other structs, and data values will
% all be empty matrix.
function merged_struct = MergeFields( dim, varargin)

    % Find the unique field names that exist across all structs
    FieldNames = {};
    for i = 1 : length( varargin)
        input_struct = varargin{i};
        if( ~isempty( input_struct))
            field_names = fieldnames( input_struct);
            FieldNames = [FieldNames; field_names];
        end
    end
    UniqueFieldNames = unique( FieldNames);
    
    % Make the fields match
    for i = 1 : length( varargin)
        if( isempty( varargin{i}))
            % If input is empty, fill it in with all the unique field names
            % and assign empty matrix for values
            varargin{i} = cell2struct( repmat({[]},size(UniqueFieldNames)), UniqueFieldNames, 1);
            continue;
        end
        field_names = fieldnames( varargin{i});
        missing_names = setdiff( UniqueFieldNames, field_names);
        % Fill in the missing fields
        for m = 1 : length( missing_names)
            missing_name = missing_names{m};
            varargin{i}.(missing_name) = [];
        end
        % Make sure field names in output are in the same order as
        % UniqueFieldNames (i.e. alphabetic order)
        varargin{i} = orderfields( varargin{i}, UniqueFieldNames);
    end
    
    % Now we can concatenate the structs because we know the field names
    % match
    merged_struct = cat( dim, varargin{:});
    