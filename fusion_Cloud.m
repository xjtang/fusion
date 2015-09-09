% fusion_Cloud.m
% Version 2.0
% Step 3
%
% Project: New Fusion
% By xjtang
% Created On: 11/24/2014
% Last Update: 8/25/2015
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
% Version 1.0 - 11/25/2014
%   This script generates plot and table for cloud statistics of the MOD09SUB data.
%   
% Updates of Version 1.1 - 11/26/2014
%   1.Seperate year and doy.
%
% Updates of Version 1.2 - 12/12/2014
%   1.Added support for aqua.
%   2.Added a new function of discarding cloudy swath based on cloud percent threshold.
%
% Updates of Version 1.2.1 - 2/11/2015
%   1.Bug fixed.
%
% Updates of Version 1.3 - 4/6/2015
%   1.Combined 250m and 500m fusion.
%
% Updates of Version 1.3.1 - 7/1/2015
%   1.Adde Landsat scene information.
%
% Update of Version 2 - 8/25/2015
%   1.Promoted into a main function.
%
% Created on Github on 11/24/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function fusion_Cloud(main)

	% get list of all valid files in the input directory
    fileList = dir([main.output.modsub,main.set.plat,'09SUB*','ALL*.mat']);

    % check if list is empty
    if numel(fileList)<1
        disp('Cannot find any .mat file.');
        return;
    end

    % initiate results
    perCloud = zeros(numel(fileList),1);
    dateYear = zeros(numel(fileList),1);
    dateDOY = zeros(numel(fileList),1);

    % loop through all files in the list
    for i = 1:numel(fileList)

        % load the .mat file
        MOD09SUB = load([main.output.modsub,fileList(i).name]);

        % total number of swath observation
        nPixel = numel(MOD09SUB.MODLine250)*numel(MOD09SUB.MODSamp250);

        % total cloudy
        nCloud = sum(MOD09SUB.QACloud250(:));

        % insert result
        perCloud(i) = round(nCloud/nPixel*1000)/10;
        p = regexp(fileList(i).name,'\d\d\d\d\d\d\d');
        dateYear(i) = str2double(fileList(i).name(p:(p+3)));
        dateDOY(i) = str2double(fileList(i).name((p+4):(p+6)));

        % discard current swath if cloud percent larger than certain threshold
        dumpDir = [main.output.dump 'P' num2str(main.set.scene(1),'%03d') 'R' num2str(main.set.scene(2),'%03d') '/SUBCLD/'];
        if exist(dumpDir,'dir') == 0 
            mkdir(dumpDir);
        end
        if perCloud(i) > main.set.cloud
            system(['mv ',main.output.modsub,fileList(i).name,' ',dumpDir]);
        end

    end
  
    % save result
    outFile = [main.outpath,'cloud.csv'];
    if exist(dumpDir,'dir') == 0 
        disp('Cloud file already exist, overwrite.');
        system(['rm ',outFile]);
    end
    r = [dateYear,dateDOY,perCloud];
    dlmwrite(outFile,r,'delimiter',',','precision',10);

    % done

end