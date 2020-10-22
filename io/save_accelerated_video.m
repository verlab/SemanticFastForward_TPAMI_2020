%> @file save_accelerated_video.m
%>
%> Function to save in disk the accelerated video.
%> 
%> Functional call:
%> @code
%> save_accelerated_video(input_video_filename, output_video_filename, frames)
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

% ========================================================================
%> @brief Save in disk the selected frames to a video file.
%>
%> After saving the file, the function try to change the file permission.
%> 
%> @param paths                 - @c struct     , strcut with the paths used during the code execution.
%> @param selectedFrames        - 1 x SF @c int , vector with the SF selected frames.
%>
%> @warning The path until the file must exist. 
%>
%> @authors Felipe C. Chamone (cadar@dcc.ufmg.br) , Michel M. Silva (michelms@dcc.ufmg.br)
%> 
%> @date 11/04/2017
%>
%> @see file_management.m
%>
% ========================================================================
%% Create a new video file with the selected frames
function [ checked ] = save_accelerated_video( paths , selectedFrames )

    %% Save video using python 2.7 + OpenCV 2.4.9
    if exist('etc/create_video_from_selected_frames.py', 'file')
      
       commandStr = ['python etc/create_video_from_selected_frames.py -v ' paths.in.video ' -s ' paths.out.selectedFrames ' -o ' paths.out.outputVideo '.avi']; 
       message_handle('I','Generating video using the Python Script...');
       [status, ~] = system(commandStr);
       if status==0
           message_handle('S','Saving done using python.', 'ExtraSpace', true);
       else
           message_handle('E','Error while saving video using python.', 'ExtraSpace', true);           
       end
    
    else
        %% Save video using MATLAB VideoWriter framework.
        outputVideoFilename = [paths.out.outputVideo '.avi'];

        %% Reading input video
        message_handle('I','Reading input video...');
        reader = VideoReader(paths.in.video);
        %reader.NumberOfFrames;
        message_handle('I','Video loaded...');

        %% Video writer stuff
        writer = VideoWriter(outputVideoFilename);
        writer.FrameRate = reader.FrameRate;
        writer.open();

        numFrames = size(selectedFrames,2);

        message_handle('S',sprintf('Video: %s| Writing %s frames to %s at %s fps...', outputVideoFilename, num2str(numFrames), outputVideoFilename, num2str(reader.FrameRate)));

        sf_iter = 1;
        video_iter = 1;

        while ( hasFrame(reader) && video_iter < selectedFrames(end) && sf_iter < length(selectedFrames))
            frame = readFrame(reader);
            if ( video_iter == selectedFrames(sf_iter) )
                writeVideo(writer, frame);
                sf_iter = sf_iter + 1;
                progress_bar(sf_iter, numFrames);
            end
            video_iter = video_iter + 1;
        end

        writer.close();    
        checked = file_management( outputVideoFilename );

        message_handle('S','Saving done.');
        
    end
end


% function save_accelerated_video_old(inputVideoFilename, outputVideoFilename, selectedFrames)
% 
%     outputVideoFilename = [outputVideoFilename '.avi'];
% 
%     %% Reading input video
%     message_handle('I','Reading input video...');
%     reader = VideoReader(inputVideoFilename);
%     reader.NumberOfFrames;
%     message_handle('I','Video loaded...');
%     
%     %% Video writer stuff
%     writer = VideoWriter(outputVideoFilename);
%     writer.FrameRate = reader.FrameRate;
%     writer.open();
%     
%     numFrames = size(selectedFrames,2);
%     
%     message_handle('S',sprintf('Writing %s frames to %s at %s fps...', num2str(numFrames), outputVideoFilename, num2str(reader.FrameRate)));
%     
%     for i=1:numFrames
%         frame = read(reader,selectedFrames(i));
%         writeVideo(writer, frame);
%         progress_bar(i, numFrames)
%     end
%     
%     writer.close();    
%     file_management( outputVideoFilename );
%     
%     message_handle('S','Saving done.');
% end
