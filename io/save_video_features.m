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

%> @file save_video_features.m
%>
%> Function to save the video features in disk.
%> 
%> Functional call:
%> @code
%> [ success ] = save_video_features(videoFeaturesFile, filename)
%> @endcode

% ========================================================================
%> @brief Save the video features in a file.
%>
%> Save the MATLAB variable in disk. After saving the file, the function try to change the file permission.
%>
%> @param videoFeaturesFile - @c MATLAB , MATLAB struct with the video features matrix and Optical Flow descriptor.
%> @param filename          - @c string , complete path, with filename and MAT extension to save the file.
%> 
%> @retval sucess           - @c bool   , return the status of the changing file permission.
%> 
%> @warning The file permission used into this function is compatible with UNIX systems. If used in Windows Operational System, change the permissions attributes.
%>
%> @author Michel M. Silva (michelms@dcc.ufmg.br)
%>
%> @date 24/08/2017 
%>
%> @see file_management.m
% ========================================================================
function [ success ] = save_video_features(videoFeaturesFile, filename)

    if isempty(videoFeaturesFile)
        message_handle('E',' Error during saving the file videoFeature: File empty.');
    else
        save(filename, 'videoFeaturesFile');
        success = file_management(filename);
    end

end