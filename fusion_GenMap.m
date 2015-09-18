% fusion_GenMap.m
% Version 1.1
% Step 9
% Generate Map

% Project: New Fusion
% By xjtang
% Created On: 7/7/2014
% Last Update: 9/18/2015
%
% Input Arguments: 
%   main (Structure) - main inputs of the fusion process generated by fusion_inputs.m.
%   
% Output Arguments: NA
%
% Instruction: 
%   1.Customize a config file for your project.
%   2.Run fusion_Inputs() first and get the returned structure of inputs
%   3.Run previous steps first to make sure required data are already generated.
%   4.Run this function with the stucture of inputs as the input argument.
%
% Version 1.0 - 7/7/2015
%   This script generates change map in envi format based on fusion result.
%
% Updates of Version 1.0.1 - 7/13/2015
%   1.Added a new type of map.
%
% Updates of Version 1.0.2 - 7/18/2015
%   1.Added support for new model parameter.
%
% Updates of Version 1.0.3 - 8/18/2015
%   1.Fixed a bug that may cause the script to delete other files.
%
% Updates of Version 1.0.4 - 9/17/2015
%   1.Generaes all maps as a package now.
%   2.Added a check to see if the previous process is completed.
%
% Updates of Version 1.1 - 9/18/2015
%   1.Generates coefficients maps.
%
% Created on Github on 7/7/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function fusion_GenMap(main)
    
    % initialize
    MAP = ones(length(main.etm.line),length(main.etm.sample),4)*-9999;
    CMAP = ones(length(main.etm.line),length(main.etm.sample),length(main.model.band),4)*-9999;
    
    % start timer
    tic;
    
    % check if line catch is completed
    Complete.Check = dir([main.output.chgmat 'ts.r*.chg.mat']);
    if numel(Complete.Check)/length(main.etm.line) <= 0.7
        disp('Line cache are not complete, abort.');
        return;  
    end
    
    % line by line processing
    for i = (main.etm.line)'
        
        % check if result exist
        File.Check = dir([main.output.chgmat 'ts.r' num2str(i) '.chg.mat']);
        if numel(File.Check) == 0
            disp([num2str(i) ' line cache does not exist, skip this line.']);
            continue;  
        end
        
        % read input data
        CHG = load([main.output.chgmat 'ts.r' num2str(i) '.chg.mat']);
        
        % processing
        for j = main.etm.sample
            
            % subset data
            X = squeeze(CHG.Data(j,:));
            
            % see if this pixel is eligible
            if max(X) <= 0
                continue
            end
            
            % assign change map result
            MAP(i,j,1) = genMap(X,CHG.Date,1,[main.model.chgedge,main.model.nonfstedge],main.model.probThres);
            MAP(i,j,2) = genMap(X,CHG.Date,2,[main.model.chgedge,main.model.nonfstedge],main.model.probThres);
            MAP(i,j,3) = genMap(X,CHG.Date,3,[main.model.chgedge,main.model.nonfstedge],main.model.probThres);
            MAP(i,j,4) = genMap(X,CHG.Date,4,[main.model.chgedge,main.model.nonfstedge],main.model.probThres);
            
            % assign coef map result
            CMAP(i,j,:,1) = CHG.Coef(1,j,:);
            CMAP(i,j,:,2) = CHG.Coef(2,j,:);
            CMAP(i,j,:,3) = CHG.Coef(3,j,:);
            CMAP(i,j,:,4) = CHG.Coef(4,j,:);
            
        end 
        
        % clear processed line
        clear 'CHG';
        
        % show progress
        disp(['Done with line ',num2str(i),' in ',num2str(toc,'%.f'),' seconds']);
        
    end
    
    % export change maps
    for i = 1:4
        
        % determine file name
        if i == 1
            outFile = [main.output.chgmap 'DateOfChange'];
        elseif i == 2
            outFile = [main.output.chgmap 'MonthOfChange'];
        elseif i == 3
            outFile = [main.output.chgmap 'ClassMap'];
        elseif i == 4
            outFile = [main.output.chgmap 'ChangeOnly'];
        end

        % see if change map already exist
        if exist(outFile,'file')
            disp('Change map already exist, overwrite.')
            system(['rm ',outFile]);
            system(['rm ',[outFile,'.hdr']]);
        end

        % export change map
        enviwrite(outFile,squeeze(MAP(:,:,i)),[main.etm.ulEast,main.etm.ulNorth],main.etm.utm,3,[30,30],'bsq');

    end
        
    % export coef maps
    for i = 1:4
        
        % determine file name
        if i == 1
            outFile = [main.output.coefmap 'PreStd'];
        elseif i == 2
            outFile = [main.output.coefmap 'PreMean'];
        elseif i == 3
            outFile = [main.output.coefmap 'PostStd'];
        elseif i == 4
            outFile = [main.output.coefmap 'PostMean'];
        end

        % see if change map already exist
        if exist(outFile,'file')
            disp('Coef map already exist, overwrite.')
            system(['rm ',outFile]);
            system(['rm ',[outFile,'.hdr']]);
        end

        % export change map
        enviwrite(outFile,squeeze(CMAP(:,:,:,i)),[main.etm.ulEast,main.etm.ulNorth],main.etm.utm,3,[30,30],'bsq');

    end
    
    % done
    
end

