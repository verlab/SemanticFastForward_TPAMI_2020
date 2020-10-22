%> @file get_transition_costs.m
%>
%> Function to calculate the transistion cost of a segment.
%> 
%> Functional call:
%> @code
%> [ costsList ] = get_transition_costs(selectedFrames, costs, speedup);
%> @endcode

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


%% --- Calculate transition costs -----------------------------------------------------------------------------------

% ===============================================================================
%> @brief Function to calculate the transition costs between the selected frames.
%> 
%> @param selectedFrames - F x 1   @c int   , Selected frames.
%> @param costs          - F x 100 @c float , Matrix with transition costs.
%> @param speedup        - @c int           , speedup of the segment.
%>
%> @retval costsList     - F-1 x 1 @c int  , array with transition costs.
%>
%> @author Felipe C. Chamone (cadar@dcc.ufmg.br)
%>
%> @date 20/09/2017 
% ==============================================================================

function [ costsList ] = get_transition_costs(selectedFrames, costs, speedup)
    costsList = zeros(1,length(selectedFrames)-1);
    
    for i=1:(length(selectedFrames)-1)
        if ~(selectedFrames(i) > size(costs, 1))
           costsList(i) = costs(selectedFrames(i), selectedFrames(i+1)-selectedFrames(i)) * ((selectedFrames(i+1)-selectedFrames(i)- speedup ) ) ;
        end
    end
    
end