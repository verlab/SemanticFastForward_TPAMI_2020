%> @file accelerate_video_LLC.m
%>
%> Function to start the spams library, prepare the variables and invoke the adaptative_frame_selection_LLC.m
%> 
%> Functional call:
%> @code
%> [ selectedFrames ] = accelerated_video_LLC( experiment , semanticExtractor, varargin )
%> @endcode
%>
%> Possible values to varargin argument:
%> - \b Speedup             - @c integer {10}             , speed-up rate desired to accelerate the video.
%> - \b InitialFrame        - @c integer {1}              , number of the initial video segment frame.
%> - \b FinalFrame          - @c integer {video_length}   , number of the final video segment frame.
%>
%> - \b OutputPath          - @c string  {video_path/out} , complete path to save the outputs.
%> - \b GenerateVideo       - @c boolean {true}           , flag to save the accelerated video in disk.
%> - \b ShowFigures         - @c boolean {false}          , flag to show imagens during the Sparse Coding processing.
%> - \b Verbose             - @c boolean {false}          , flag to display processing debug messages.
%>
%> - \b UseCNNFeatures      - @c boolean {false}          , flag to execute to load the deep video features.
%> - \b FillGapCorrection   - @c boolean {true}           , flag to execute frame sampling step using Fill Gap Correction approach.
%> - \b MultiImportance     - @c boolean {true}           , flag to execute the Multi-Importance Semantic approach.
%>
%> - \b SpeedupFactor       - @c integer {2}              , speed-up rate factor used to multiply the desired accelerate the video while calling the speed-up video function.
%> - \b LoadVideoFeatures   - @c boolean {true}           , flag to indicate if the path to the file with the video features exists.

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ========================================================================
%> @brief Function to exectute the following steps to call the Adaptive frame selection via Sparse Coding:
%> - start spams libraty
%> - load video features
%> - calculate speed-up rates and ranges
%> - frame sampling
%> - regarding the GenerateVideo value, it saves the video.
%>
%> @param inputVideo        - @c string       , experiment identifier.
%> @param semanticExtractor - @c string       , extractor type [ 'pedestrian' | 'face' ]
%> @param varargin          - 1 X A @c string , list of A optional arguments. 
%> - \b Speedup             - @c integer {10}             , speed-up rate desired to accelerate the video.
%> - \b InitialFrame        - @c integer {1}              , number of the initial video segment frame.
%> - \b FinalFrame          - @c integer {video_length}   , number of the final video segment frame.
%>
%> - \b OutputPath          - @c string  {video_path/out} , complete path to save the outputs.
%> - \b GenerateVideo       - @c boolean {true}           , flag to save the accelerated video in disk.
%> - \b ShowFigures         - @c boolean {false}          , flag to show imagens during the Sparse Coding processing.
%> - \b Verbose             - @c boolean {false}          , flag to display processing debug messages.
%>
%> - \b UseCNNFeatures      - @c boolean {false}          , flag to execute to load the deep video features.
%> - \b FillGapCorrection   - @c boolean {true}           , flag to execute frame sampling step using Fill Gap Correction approach.
%> - \b MultiImportance     - @c boolean {true}           , flag to execute the Multi-Importance Semantic approach.
%>
%> - \b SpeedupFactor       - @c integer {2}              , speed-up rate factor used to multiply the desired accelerate the video while calling the speed-up video function.
%> - \b LoadVideoFeatures   - @c boolean {true}           , flag to indicate if the path to the file with the video features exists.

%>
%> @retval selectedFrames   - 1 x N @c int    , vector containing the N selected frames  
%>
%> @warning If any of the paths set read or write do not exist, the **program will be killed**.
%>
%> @authors Michel M. Silva (michelms@dcc.ufmg.br)
%>
%> @date 05/10/2018 
%>
%> @see adaptative_frame_selection_LLC.m
% ========================================================================
function [ selectedFrames ] = accelerate_video_LLC( inputVideo , semanticExtractor, varargin )

    %% Input parse.
    p = inputParser;

    validSemanticExtractor  = {'face', 'pedestrian', 'coolnet'};
    checkSemanticExtractor  = @(x) any(validatestring(x,validSemanticExtractor));
        
    addRequired( p , 'semanticExtractor'  , checkSemanticExtractor);

    addOptional( p , 'OutputPath'         , ''                 );  
    addOptional( p , 'GenerateVideo'      , true  , @islogical );
    addOptional( p , 'Speedup'            , 10    , @isnumeric );  
    
    addOptional( p , 'MultiImportance'    , true  , @islogical );
    addOptional( p , 'FillGapCorrection'  , true  , @islogical );
    addOptional( p , 'UseCNNFeatures'     , false , @islogical );

    addOptional( p , 'InitialFrame'       , 0     , @isnumeric );  
    addOptional( p , 'FinalFrame'         , 0     , @isnumeric );  
    
    addOptional( p , 'Verbose'            , false , @islogical );
    addOptional( p , 'ShowFigures'        , false , @islogical );
    
    addOptional( p , 'SpeedupFactor'      , 2     , @isnumeric );    
    addOptional( p , 'LoadVideoFeatures'  , true , @islogical );
    
    parse(p, semanticExtractor, varargin{:});
        
    %% Load internal libraries
    addpath( 'io' , 'features', 'etc' );
    [videoFolder, experiment, ~] = fileparts(inputVideo);
    
    %% Experiment ID and computer name.
    [ id.computer , id.experiment ] = get_experiment_info();
    message_handle('',sprintf(' Computer ID: %s | Experiment %s : %s ', id.computer, num2str(id.experiment)), ...
        'ExtraSpace',true,'TopLine',true,'BottomLine',true);
    
    %% Path Settings.

    % In.
    path.in.video              = inputVideo;
    path.in.MISFFcode          = '_SemanticFastForward_JVCI_2018/';
    path.in.semanticExtracted  = [videoFolder '/' experiment '_' semanticExtractor '_extracted.mat'];
    path.in.opticalFlowCSV     = [videoFolder '/' experiment '.csv'];
    path.in.YoloDesc           = [videoFolder '/' experiment '_yolo_desc.csv' ];
    
    if p.Results.LoadVideoFeatures
        if (p.Results.UseCNNFeatures)
            path.in.videoFeaturesCNN    = [videoFolder '/' experiment '_cnn_features.npy'];
        else
            path.in.videoFeatures       = [videoFolder '/' experiment '_video_features_whitening.mat'];
        end
    else
        path.out.videoFeatures          = [videoFolder '/' experiment '_video_features_whitening.mat'];
    end
    
    
    %Out
    if isempty(p.Results.OutputPath)
        path.out.outputDir = [videoFolder '/out'];
    else
        path.out.outputDir = p.Results.OutputPath;
    end
    
    path.out.generalResults     = [ path.out.outputDir '/' 'General_Results.csv' ];
    path.out.selectedFrames     = [ path.out.outputDir '/' experiment '_LLC_EXP_' id.computer '_' num2str(id.experiment, '%04d') '_selected_frames.csv'];
    path.out.outputVideo        = [ path.out.outputDir '/' experiment '_LLC_EXP_' id.computer '_' num2str(id.experiment, '%04d') ];
    path.out.generateVideoPy    = [ path.out.outputDir '/generate_video_' experiment '.py'];
    path.out.costsMatrix        = [ videoFolder '/' experiment '_Costs_' num2str(p.Results.Speedup) 'x.mat' ];
    
    %% Path check.
    if ~check_paths(path);
        message_handle('E', 'Exiting due to an error during the path checking.');
        return;
    end

    %% Load external libraries.
    addpath( path.in.MISFFcode );
    addpath( [ path.in.MISFFcode 'SemanticScripts' ] );
    addpath( [ path.in.MISFFcode 'PSOScripts' ] );
    addpath( [ path.in.MISFFcode 'Util' ] );

    %% Video features.
    if p.Results.LoadVideoFeatures
        myFile = load(path.in.videoFeatures);
        videoFeaturesFile = myFile.videoFeaturesFile;
    else
        [ videoFeaturesFile.descriptors, videoFeaturesFile.OF ] = video_features_frames(path.in.video, path.in.opticalFlowCSV, path.in.semanticExtracted, path.in.YoloDesc);
        save_video_features(videoFeaturesFile, path.out.videoFeatures);
    end
    
    videoFeatures = videoFeaturesFile.descriptors;
    OF = videoFeaturesFile.OF;
    
    if (p.Results.UseCNNFeatures)
        addpath('_npy-matlab/');
        myfile = readNPY(path.in.videoFeaturesCNN);
        videoFeatures = squeeze(myfile(:,1,:,:));
        videoFeatures = videoFeatures';
        rmpath('_npy-matlab');
    end
        
    nFrames = size(videoFeatures,2);
    
    %% Video segment.    
    initialFrame = 1;
    finalFrame = size(videoFeatures,2);
    
    if p.Results.InitialFrame > 0
        initialFrame = p.Results.InitialFrame;
    end
    if p.Results.FinalFrame > 0
        finalFrame = p.Results.FinalFrame;
    end
    
    
    %% Calculating semantic and non-semantic speed-up using PSO.
    % ***JVCI Code***.
    [speedupRates, ~, rangesAndSpeedups, ~, ~, ~] = CalculateSpeedupRates(path.in.semanticExtracted, p.Results.Speedup, 'MultipleThresholds', p.Results.MultiImportance, 'InputRange', [initialFrame, finalFrame]);
    ranges = AddNonSemanticRanges(rangesAndSpeedups, speedupRates, initialFrame, finalFrame, 150);
    % ***JVCI Code***.
    
    %% Costs
    generate_transistion_costs(inputVideo, p.Results.Speedup, semanticExtractor)
        
    distanceOneHot = time_features(nFrames, 100 );
    videoFeatures = whitening_matrix( [videoFeatures;distanceOneHot]' )';          
        
    %% Calculate weight.
    weights = get_weights_CDC( OF' );
    
    videoFeatures = videoFeatures(:,initialFrame:finalFrame);
    weights = weights(initialFrame:finalFrame,:);
    ranges(1:2,:) = ranges(1:2,:) - initialFrame + 1;
    
    tic;
    
    %% Frame Selection.
    [selectedFrames, speedups, ~] = adaptative_frame_selection_LLC(videoFeatures, ranges, path.out.costsMatrix , 'ShowFigures', p.Results.ShowFigures, ...
        'Verbose', p.Results.Verbose, 'Weights', weights, 'SpeedupFactor',p.Results.SpeedupFactor, 'InitialFrame', initialFrame, 'FillGapCorrection', p.Results.FillGapCorrection);
    
    executionTime = toc;
    
    message_handle( 'S' , sprintf('Final Video Speed-up: %f',speedups.final),'ExtraSpace',true);
    
    if p.Results.Verbose
        message_handle( 'L' , sprintf('Speed-up required by the CalculateSpeedupRates PSO function %2.2f', speedups.PSO) );
        message_handle( 'L' , sprintf('Speed-up required after the gap smoothing step %2.2f', speedups.newRanges) );
    end
    
    %% Output view.
    if p.Results.ShowFigures
        pause; 
        close all;
    end

    ranges(1:2,:) = ranges(1:2,:) + initialFrame - 1;
    write_selected_frames(path.out.selectedFrames, speedups.speedupPerFrame, selectedFrames);
    write_general_results(path.out.generalResults, id, experiment, 'LLC', semanticExtractor, p, speedups, executionTime);
    
    %% Save final video.
    if p.Results.GenerateVideo
        save_accelerated_video( path , selectedFrames );
    end
    
    rmpath( path.in.MISFFcode );
    rmpath( [ path.in.MISFFcode 'SemanticScripts' ] );
    rmpath( [ path.in.MISFFcode 'PSOScripts' ] );
    rmpath( [ path.in.MISFFcode 'Util' ] );
    rmpath( 'io' , 'features', 'etc' );
    
end
