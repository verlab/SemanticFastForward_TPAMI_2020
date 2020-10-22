%> @file calculate_speedup_ranges.m
%>
%> Functions to calculate the speed-up rates over the segments.
%> 
%> Function call:
%> @code
%> [ speedup ] = calculate_speedup_ranges( ranges )
%> @endcode
%>
%> Possible values to varargin argument:
%> - \b Verbose             - @c boolean      , flag to display processing debug messages.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   This file is part of SparseSampling@TPAMI2020.
%
%    SparseSampling@TPAMI2020 is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    SparseSampling@TPAMI2020 is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with SparseSampling@TPAMI2020.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ========================================================================
%> @brief Calculate the expected speedup rate using ranges.
%> 
%> @param  ranges  - 4 x N @c int , ranges in form of a matrix with dimensions 4 by N ( number of segments ).
%> @param varargin          - 1 X A @c string , list of A optional arguments. 
%> - \b Verbose             - @c boolean      , flag to display processing debug messages.
%>
%> @retval speedup - @c double , speed-up rate expected.
%>
%> @author Felipe C. Chamone (cadar@dcc.ufmg.br) and Michel M. Silva (michelms@dcc.ufmg.br)
%> 
%> @date 10/04/2018
% ========================================================================
function [ speedup ] = calculate_speedup_ranges( ranges , varargin )

    p = inputParser;
    
    addOptional( p , 'Verbose'            , false  , @islogical );
    
    parse(p, varargin{:});

    if isempty(ranges)
       speedup = 0;
       return;
    end
    
    totalFrames = ranges(2, end) - ranges(1,1) + 1;
    selectedFrames = 0;

    for i=1:size(ranges, 2)

        desiredSpeedup = ranges(3, i);
        frames = ranges(2, i) - ranges(1, i) + 1;
        semantic = ranges(4, i); 

        selectedFrames = selectedFrames + round(frames/desiredSpeedup);

        if ( p.Results.Verbose )
            message_handle('L',sprintf('Seg: %3d | Desired Speedup %2d | Size %6d | Semantic %d', i, desiredSpeedup, frames, semantic) );
        end
    end

    speedup = totalFrames / selectedFrames;
    
    if ( p.Results.Verbose )
        message_handle('I', sprintf('Final speedup: %2.2d | Selected Frames:  %6d | Original frames: %6d.', speedup, selectedFrames, totalFrames), 'ExtraSpace',true);
    end
end
