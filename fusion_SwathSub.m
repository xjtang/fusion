% fusion_SwathSub.m
% Version 6.3.1
% Step 2
% Subsetting the Swath Data
%
% Project: New Fusion
% By xjtang
% Created On: Unknown
% Last Update: 11/2/2015
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
% Version 6.0 - Unknown (by Q. Xin)
%   This script subsets original MODIS swath data to fit the coverage of a Landsat ETM image. the subset and related information.
%
% Updates of Version 6.1 - 10/1/2014 
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%   4.Changed from script to function
%   5.Modified the code to incorporate the use of fusion_inputs structure.
%   6.Added processing of two other MODIS land bands (correspond to Landsat band 5 and 7)
%
% Updates of Version 6.1.1 - 10/10/2014 
%   1.automatically skip if output file already exist.
%
% Updates of Version 6.2 - 12/1/2014 
%   1.Bug fixed.
%   2.Added support for 250m.
%   3.Updated comments.
%   4.Added support for MODIS Aqua
%   5.Automatically remove swath that does not cover roi.
%
% Updates of Version 6.2.1 - 12/12/2014 
%   1.Move non-usable swath to DUMP instead of deleting.
%
% Updates of Version 6.3 - 4/3/2015 
%   1.Combined 250m and 500m fusion.
%
% Updates of Version 6.3.1 - 11/2/2015
%   1.Added support for consolidating study of multiple landsat scenes.
%
% Released on Github on 10/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function fusion_SwathSub(main)

    % MOD09 Swath Info
    % FileName.Day=datenum(2003,9,1);	% nadir image
    % FileName.Day=datenum(2000,9,12);	% two images
    % FileName.Day=datenum(2000,9,17);	% off-nadir image

    % start the timer
    tic;
    
    % loop through all files
    for I_Day = 1:numel(main.date.swath)
        
        % check platform
        plat = main.set.plat;
        
        % find files
        Day = main.date.swath(I_Day);
        DayStr = num2str(Day);
        File.MOD09 = dir([main.input.swath,plat,'09.A',DayStr,'*']);

        % all files exist
        if numel(File.MOD09)<1
            disp(['Cannot find Swath for Julian Day: ', DayStr]);
            continue;
        end

        % loop through MODIS swath images of that date
        for I_TIME = 1:numel(File.MOD09)
            
            
            
            % construct time string
            TimeStr = regexp(File.MOD09(I_TIME).name,'\.','split');
            TimeStr = char(TimeStr(3));
            
            % check if file already exist
            output = [main.output.modsub,plat,'09SUB.','ALL.',DayStr,'.',TimeStr,'.mat'];
            if exist(output,'file')>0 
                disp([output ' already exist, skip one'])
                continue;
            end
            
            % initialize MOD09SUB
            MOD09SUB = [];

            % interpolate swath geolocation data
            Lat1km = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],'Latitude' ));
            Lon1km = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],'Longitude'));
            Lat250 = geoInterpMODIS(Lat1km,250);
            Lat500 = geoInterpMODIS(Lat1km,500);
            Lon250 = geoInterpMODIS(Lon1km,250);
            Lon500 = geoInterpMODIS(Lon1km,500);
            
            % convert to UTM
            [East250,North250,~] = deg2utm(Lat250,Lon250,main.etm.utm);
            [East500,North500,~] = deg2utm(Lat500,Lon500,main.etm.utm);
            
            % create mask for area outside the coverage of Landsat image
            Mask250 = (East250>main.etm.subULEast & East250<main.etm.subLREast & ...
                North250<main.etm.subULNorth & North250>main.etm.subLRNorth);
            Mask500 = (East500>main.etm.subULEast & East500<main.etm.subLREast & ...
                North500<main.etm.subULNorth & North500>main.etm.subLRNorth);
            
            % find lines and samples in swath data that is not masked
            [Row250,Col250] = find(Mask250>0);
            [Row500,Col500] = find(Mask500>0);
            NLine250 = 1000/250*10;
            NLine500 = 1000/500*10;
            MOD09SUB.MODLine250 = (floor(min(Row250)/NLine250)*NLine250+1:ceil(max(Row250)/NLine250)*NLine250)';
            MOD09SUB.MODSamp250 = (min(Col250):max(Col250));
            MOD09SUB.MODLine500 = (floor(min(Row500)/NLine500)*NLine500+1:ceil(max(Row500)/NLine500)*NLine500)';
            MOD09SUB.MODSamp500 = (min(Col500):max(Col500));

            % loop through all non-masked lines
            if numel(MOD09SUB.MODLine250)>0 && numel(MOD09SUB.MODLine500)>0
                
                % get swath observation geometry for sub_image
                [~,ViewAngle250,SizeAlongScan250,SizeAlongTrack250]= swathGeo(250);
                MOD09SUB.SizeAlongScan250 = ones(numel(MOD09SUB.MODLine250),1)*SizeAlongScan250(MOD09SUB.MODSamp250);
                MOD09SUB.SizeAlongTrack250 = ones(numel(MOD09SUB.MODLine250),1)*SizeAlongTrack250(MOD09SUB.MODSamp250);
                MOD09SUB.ViewAngle250 = ones(numel(MOD09SUB.MODLine250),1)*ViewAngle250(MOD09SUB.MODSamp250);
                [~,ViewAngle500,SizeAlongScan500,SizeAlongTrack500]= swathGeo(500);
                MOD09SUB.SizeAlongScan500 = ones(numel(MOD09SUB.MODLine500),1)*SizeAlongScan500(MOD09SUB.MODSamp500);
                MOD09SUB.SizeAlongTrack500 = ones(numel(MOD09SUB.MODLine500),1)*SizeAlongScan500(MOD09SUB.MODSamp500);
                MOD09SUB.ViewAngle500 = ones(numel(MOD09SUB.MODLine500),1)*ViewAngle500(MOD09SUB.MODSamp500);
                
                % get swath observation latitude and longitude
                MOD09SUB.Lat250 = Lat250(MOD09SUB.MODLine250,MOD09SUB.MODSamp250);
                MOD09SUB.Lon250 = Lon250(MOD09SUB.MODLine250,MOD09SUB.MODSamp250);
                MOD09SUB.Lat500 = Lat500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);
                MOD09SUB.Lon500 = Lon500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);

                % get swath reflectance
                MOD09RED250 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],['250','m Surface Reflectance Band 1']));
                MOD09NIR250 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],['250','m Surface Reflectance Band 2']));
                MOD09SUB.MOD09RED250 = MOD09RED250(MOD09SUB.MODLine250,MOD09SUB.MODSamp250);
                MOD09SUB.MOD09NIR250 = MOD09NIR250(MOD09SUB.MODLine250,MOD09SUB.MODSamp250);  
                MOD09RED500 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],['500','m Surface Reflectance Band 1']));
                MOD09NIR500 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],['500','m Surface Reflectance Band 2']));
                MOD09SUB.MOD09RED500 = MOD09RED500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);
                MOD09SUB.MOD09NIR500 = MOD09NIR500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);
                MOD09BLU500 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],['500','m Surface Reflectance Band 3']));
                MOD09GRE500 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],['500','m Surface Reflectance Band 4']));
                MOD09SUB.MOD09BLU500 = MOD09BLU500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);
                MOD09SUB.MOD09GRE500 = MOD09GRE500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);
                MOD09SWIR500 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],['500','m Surface Reflectance Band 6']));
                MOD09SWIR2500 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],['500','m Surface Reflectance Band 7']));
                MOD09SUB.MOD09SWIR500 = MOD09SWIR500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);
                MOD09SUB.MOD09SWIR2500 = MOD09SWIR2500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);

                % get swath QA
                MODISQA = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],'1km Reflectance Data State QA'));
                MODISQA250 = kron(MODISQA,ones(1000/250));
                MOD09SUB.MODISQA250 = MODISQA250(MOD09SUB.MODLine250,MOD09SUB.MODSamp250);
                MODISQA500 = kron(MODISQA,ones(1000/500));
                MOD09SUB.MODISQA500 = MODISQA500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);

                % get band QA
                BandQA250 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],['250','m Reflectance Band Quality']));
                MOD09SUB.BandQA250 = BandQA250(MOD09SUB.MODLine250,MOD09SUB.MODSamp250);
                BandQA500 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],['500','m Reflectance Band Quality']));
                MOD09SUB.BandQA500 = BandQA500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);

                % get ETM Line & Sample for the MODIS subimage
                East250 = East250(MOD09SUB.MODLine250,MOD09SUB.MODSamp250);
                North250 = North250(MOD09SUB.MODLine250,MOD09SUB.MODSamp250);
                MOD09SUB.ETMLine250 = (main.etm.ulNorth-North250)/30;
                MOD09SUB.ETMSamp250 = (East250-main.etm.ulEast)/30;
                East500 = East500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);
                North500 = North500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500);
                MOD09SUB.ETMLine500 = (main.etm.ulNorth-North500)/30;
                MOD09SUB.ETMSamp500 = (East500-main.etm.ulEast)/30;

                % get bearing
                Bearing250 = nan(size(MOD09SUB.Lat250));
                [~, Bearing250(:,1:end-1)] = pos2dist(MOD09SUB.Lat250(:,1:end-1),MOD09SUB.Lon250(:,1:end-1),...
                    MOD09SUB.Lat250(:,2:end),MOD09SUB.Lon250(:,2:end));
                Bearing250(:,end) = 2*Bearing250(:,end-1)-Bearing250(:,end-2);
                MOD09SUB.Bearing250 = Bearing250;
                Bearing500 = nan(size(MOD09SUB.Lat500));
                [~, Bearing500(:,1:end-1)] = pos2dist(MOD09SUB.Lat500(:,1:end-1),MOD09SUB.Lon500(:,1:end-1),...
                    MOD09SUB.Lat500(:,2:end),MOD09SUB.Lon500(:,2:end));
                Bearing500(:,end) = 2*Bearing500(:,end-1)-Bearing500(:,end-2);
                MOD09SUB.Bearing500 = Bearing500;
                
                % get QA data
                MOD09SUB = swathInterpQA(MOD09SUB);

                % save and end timer
                save([main.output.modsub,plat,'09SUB.','ALL.',DayStr,'.',TimeStr,'.mat'],'-struct','MOD09SUB');
                disp(['Done with ',DayStr,' in ',num2str(toc,'%.f'),' seconds']);
            else
                disp(['No points in: ',File.MOD09(I_TIME).name]);
%                 dumpDir = [main.output.dump 'SWATHNA/'];
%                 if exist(dumpDir,'dir') == 0 
%                     mkdir(dumpDir);
%                 end
%                 system(['mv ',main.input.swath,File.MOD09(I_TIME).name,' ',dumpDir]);
            end
        end
    end

    % done
    
end
