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

% 1- Before we start lets save sobre Bash variables to falicitate the paths

% First open the Linux bash, go to the project folder and run:

$ MIFF=$PWD

% Now go to the folder you cloned from Darknet repository and run:

$ DARKNET=$PWD

% 1- Download our example video (in Linux bash) and move it to a new folder "Example" in the project folder

$ cd $MIFF; mkdir Example; cd Example

$ wget www.verlab.dcc.ufmg.br/semantic-hyperlapse/data/video-example/example.mp4

% 2- Extract the optical flow information (in Windows CMD). The output file name must be the same name of the input video using the extesion ".csv".

% Vid2OpticalFlowCSV.exe -v < video_file > -c < config_file > -o < output_file >

$ ./Vid2OpticalFlowCSV.exe -v example.mp4 -c default-config.xml -o example.csv

% 3- Extract semantic information from video with "_SemanticFastForward_JVCI_2018/SemanticScripts/ExtractAndSave.m". Output file will be placed on the input video folder, with video file name, followed by the semantic extractor and the suffix "extracted.mat". Example: "example_face_extracted.mat".

% On MATLAB console, go to the project folder and run the following commands:

% ExtractAndSave(< video_file_path >, < semantic_extractor >);

>> addpath('SemanticScripts');
>> ExtractAndSave('Example/example.mp4', 'face');

% Results for steps 2 (example.csv) and 3 (example_face_extracted.mat) for this example video are available for download using the link:

$ cd $MIFF/Example

$ wget www.verlab.dcc.ufmg.br/semantic-hyperlapse/data/video-example/example.csv

$ wget www.verlab.dcc.ufmg.br/semantic-hyperlapse/data/video-example/example_face_extracted.mat

% 4- Extract the Yolo Features.

% On the terminal(Linux bash) go to the folder you cloned from Darknet repository and run the following commands:
% (if you cloned the Darknet repository in the project folder it should look like this)

$ cd $DARKNET

$ ./darknet detector demo cfg/coco.data cfg/yolo.cfg yolo.weights $MIFF/Example/example.mp4 $MIFF/Example/example_yolo_raw.txt

$ cd $MIFF

$ python generate_descriptor.py Example/example.mp4 Example/example_yolo_raw.txt Example/example_yolo_desc.csv

% Results for step 4 (example_yolo_raw.txt and example_yolo_desc.csv) for this example video are available for download using the link:

$ cd $MIFF/Example

$ wget www.verlab.dcc.ufmg.br/semantic-hyperlapse/data/video-example/example_yolo_raw.txt

$ wget www.verlab.dcc.ufmg.br/semantic-hyperlapse/data/video-example/example_yolo_desc.csv

% 4- To generate the final hyperlapse video, use the "accelerate_video_LLC" function.

% On MATLAB console, go to the project folder and run the following commands:

% accelerate_video_LLC( < video_path > , < semantic_extractor >, [Descriptor] [WeightMode] [CostsMode] [Speedup] [SpeedupFactor] [LoadVideoFeatures]
%                                                                [MultiImportance] [KTS] [ShowFigures] [Verbose] [GenerateVideo] );

>> accelerate_video_LLC( '<video_folder>/example.mp4' , 'face', 'GenerateVideo', false);

% The user may set the optional argument 'GenerateVideo' as false to avoid generate the output video during the search.