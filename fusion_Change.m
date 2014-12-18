% fusion_Change.m
% Version 6.1
% Step 5
% Change Detection
%
% Project: Fusion
% By Xiaojing Tang
% Created On: 12/16/2014
% Last Update: 12/16/2014
%
% Input Arguments: 
%   main (Structure) - main inputs of the fusion process generated by
%     fusion_inputs.m.
%
% Output Arguments: NA
%
% Usage: 
%   1.Customize the main input file (fusion_inputs.m) with proper settings
%       for specific project.
%   2.Run fusion_Inputs() first and get the returned structure of inputs
%   3.Run previous steps first to make sure required data are already
%       generated.
%   4.Run this function with the stucture of inputs as the input argument.
%
% Version 6.0 - 12/16/2014
%   This script detects change for the fusion process.
%
% Released on Github on 12/16/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function fusion_Change(main)

    % calculate pixel center coordinates
    [Samp,Line] = meshgrid(main.etm.sample,main.etm.line);
    ETMGeo.Northing = main.etm.ulNorth-Line*30+15;
    ETMGeo.Easting = main.etm.ulEast +Samp*30-15;
    [ETMGeo.Lat,ETMGeo.Lon] = utm2deg(ETMGeo.Easting,ETMGeo.Northing,main.etm.utm);
    ETMGeo.Line = main.etm.line;
    ETMGeo.Samp = main.etm.sample;

    % start timer
    tic;
    
    % check platform
    plat = main.set.plat;
    
    

    % done
    
end
