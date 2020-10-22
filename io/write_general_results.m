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

%> @file write_general_results.m
%>
%> Function to print in a CSV file the informations about the experiments.
%> 
%> Functional call:
%> @code
%> checked = write_general_results ( filename , id, experiment, semanticExtractor, inputParse )
%> @endcode

% ========================================================================
%> @brief Print the formatted informations information about the experiments into a CSV file.
%>
%> @param   filename          - @c string , complete path and name with extension to the file.
%> @param   id                - @c struct , struct with the fields experiments and computer.
%> @param   experiment        - @c string , experiment name.
%> @param   experimentType    - @c string , experiment type [ 'SC' | 'LLC' ].
%> @param   semanticExtractor - @c string , semantic used to extract the information.
%> @param   inputParse        - @c struct , struct with all input arguments received during the program calling.
%> @param   speedups          - @c struct , struct with three float values containing the PSO, GapSmoothing, and final calculated speed-ups.
%> @param   executionTime     - @c float, execution time to perform frame sampling, in seconds.
%>
%> @retval  checked           - @c bool   , indicates if the file was correctly created and the permissions were changed.
%>
%> @author Michel M. Silva (michelms@dcc.ufmg.br)
%>
%> @date 11/04/2018 
% ========================================================================
function checked = write_general_results ( filename , id, experiment, experimentType, semanticExtractor, inputParse, speedups, executionTime )

    fileExists = exist(filename, 'file');
    fid = fopen(filename,'a');
    
    if fid < 0 
        checked = false;
        return
    end
        
    if ~fileExists 
        header = 'Experiment_ID,Experiment,Experiment_Type,Semantic_Extractor,Multi_Importance,Computer,Speed_up_Required,Speed_up_factor,Speed_up_PSO,Speed_up_new_Ranges,UseCNNFeatures,FillGapCorrection,Speed_up_Final,Date,ExecutionTime\n';
        fprintf(fid, header);
        file_management(filename);
    end
    
    LogicalStr = {'false', 'true'};
    date = log_line_prefix;
    
    newEntry = [num2str(id.experiment) ',' experiment ',' experimentType ',' semanticExtractor ',' ...
        LogicalStr{inputParse.Results.MultiImportance + 1} ',' id.computer ',' num2str(inputParse.Results.Speedup) ',' ...
        num2str(inputParse.Results.SpeedupFactor) ',' num2str(speedups.PSO) ',' num2str(speedups.newRanges) ',' LogicalStr{inputParse.Results.UseCNNFeatures + 1} ',' ...
        LogicalStr{inputParse.Results.FillGapCorrection + 1} ',' num2str(speedups.final) ',' ...
        date(2:end-4) ',' num2str(executionTime) '\n'];
    
    fprintf(fid, newEntry);
    checked = ~fclose(fid);
end
