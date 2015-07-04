% fusion_Change.m
% Version 1.0
% Step 8
% Detect Change
%
% Project: New Fusion
% By xjtang
% Created On: 7/1/2015
% Last Update: 7/1/2015
%
% Input Arguments: 
%   main (Structure) - main inputs of the fusion process generated by fusion_inputs.m.
%
% Output Arguments: NA
%
% Instruction: 
%   1.Customize the main input file (fusion_inputs.m) with proper settings for specific project.
%   2.Run fusion_Inputs() first and get the returned structure of inputs
%   3.Run previous steps first to make sure required data are already generated.
%   4.Run this function with the stucture of inputs as the input argument.
%
% Version 1.0 - 7/1/2015
%   This script detect change in fusion time series.
%
% Released on Github on 7/1/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function fusion_Change(main)
    
    % calculate the lines that will be processed by this job
    njob = main.set.job(2);
    thisjob = main.set.job(1);
    if njob >= thisjob && thisjob >= 1 
        % subset lines
        jobLine = thisjob:njob:line;
    else
        jobLine = 1:line;
    end

    % start timer
    tic;

    % line by line processing
    for i = jobLine
        
        % check if cache exist
        
        
        
        
        
        % save current file
        save([main.output.cache 'chg.r' i '.mat'],'CHG')
        disp(['Done with line',i,' in ',num2str(toc,'%.f'),' seconds']); 
        
    end
    
    % done
    
end
