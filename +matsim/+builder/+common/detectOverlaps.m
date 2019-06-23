function [overlap_exists, overlaps] = detectOverlaps(baseBlock, otherBlocks, varargin)
% DETECTOVERLAPS Detect whether a block physically overlaps any other block
% in Simulink.
%
% Inputs:
%   baseBlock   Simulink block. We're checking if any other block
%               overlaps this.
%   otherBlocks List (cell array or vector) of Simulink blocks (fullnames or
%               handles).
%   varargin	Parameter-Value pairs as detailed below.
%
% Parameter-Value pairs:
%   Parameter: 'OverlapType'
%   Value:  {'Vertical'} - Detects any overlap with respect to top and
%               bottom positions (i.e. blocks could be offset on the
%               x-axis, but still be deemed overlapping).
%           {'Horizontal'} - Detects any overlap with respect to left
%               and right positions (i.e. blocks could be offset on the
%               y-axis, but still be deemed overlapping).
%           {'Any'} - Detects blocks with either a vertical or
%               horizontal overlap.
%           {'All'} - (Default) Detects blocks sharing space.
%   Parameter: 'VirtualBounds'
%   Value:  Position vector to add to corresponding block dimensions.
%       Intended to make near overlaps also count as overlaps. Default:
%       [0 0 0 0].
%   Parameter: 'PositionFunction'
%   Value:  Takes a function handle that will be used to determine the
%       position of a given block. It may be desirable to use this to
%       make near overlaps also count as overlaps. Default is a
%       function that just runs get_param(block, 'Position').
%
% Outputs:
%   overlap_exists  True if any overlaps were detected.
%   overlaps        Vector of Simulink blocks in otherBlocks that
%                   overlap baseBlock.


    % Handle parameter-value pairs
    OverlapType = lower('All');
    VirtualBounds = [0 0 0 0];
    PositionFunction = @getPosition;
    for i = 1:2:length(varargin)
        param = lower(varargin{i});
        value = lower(varargin{i+1});

        switch param
            case lower('OverlapType')
                assert(any(strcmp(value,lower({'Vertical','Horizontal','Any','All'}))), ...
                    ['Unexpected value for ' param ' parameter.'])
                OverlapType = value;
            case lower('VirtualBounds')
                assert(length(value) == 4, '''VirtualBounds'' parameter should be a 1x4 vector.')
                VirtualBounds = value;
            case lower('PositionFunction')
                assert(isa(value, 'function_handle'), '''PositionFunction'' parameter should be function handle.')
                PositionFunction = value;
            otherwise
                error('Invalid parameter.')
        end
    end

    %
    otherBlocks = get_param(otherBlocks,'handle');
    if iscell(otherBlocks), otherBlocks = cell2mat(otherBlocks); end

    %
    overlap_exists = false; % Guess no overlaps
    overlaps = zeros(1,length(otherBlocks));
    for i = 1:length(otherBlocks)
        block = otherBlocks(i);
        switch OverlapType
            case lower('Vertical')
                % Detect vertical overlaps
                overlapFound = isOverlap(baseBlock,block,VirtualBounds,PositionFunction,[2,4]); % Check for vertical overlap
            case lower('Horizontal')
                % Detect horizontal overlaps
                overlapFound = isOverlap(baseBlock,block,VirtualBounds,PositionFunction,[1,3]); % Check for vertical overlap
            case lower('Any')
                % Detect vertical or horizontal overlaps
                overlapFound = isOverlap(baseBlock,block,VirtualBounds,PositionFunction,[2,4]) ...
                    || isOverlap(baseBlock,block,VirtualBounds,PositionFunction,[1,3]);
            case lower('All')
                % Detect vertical and horizontal overlaps (i.e. both
                % occurring at once)
                overlapFound = isOverlap(baseBlock,block,VirtualBounds,PositionFunction,[2,4]) ...
                    && isOverlap(baseBlock,block,VirtualBounds,PositionFunction,[1,3]);
            otherwise
                error('Unexpected paramter.')
        end
        if overlapFound
            overlap_exists = true;
            overlaps(i) = block;
        end
    end
    overlaps = overlaps(find(overlaps)); % Empty elements are non-matches and should be removed
end

function bool = isOverlap(block1, block2, VirtualBounds, PositionFunction, dims)
    %
    % dims = [2,4] checks for vertical overlap
    % dims = [1,3] checks for horizontal overlap
    pos1 = PositionFunction(block1);
    pos2 = PositionFunction(block2);

    pos1 = pos1 + VirtualBounds;
    pos2 = pos2 + VirtualBounds;

    bool = matsim.builder.common.isRangeOverlap(pos1(dims),pos2(dims));
end

function pos = getPosition(block)
    pos = get_param(block, 'Position');
end
