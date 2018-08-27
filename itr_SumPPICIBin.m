%% itr_SumPPICIBin
clear all
close all

%% Parameters defined by user
project = 'SOCAL';
site = 'G2';
filePrefix = [project,site]; % File name to match. 
% File prefix should include deployment, site, (disk is optional). 
% Example: 
% File name 'GofMX_DT01_disk01-08_TPWS2.mat' 
%                    -> filePrefix = 'GofMX_DT01'
% or                 -> filePrefix ='GOM_DT_09' (for files names with GOM)
%     -> filePrefix ='SOCALA2_24' for files names SOCAL
sp = 'Cuviers'; % your species code
itnum = '2'; % which iteration you are looking for
srate = 200; % sample rate
tpwsPath = 'G:\SOCAL_BW\Detections\SOCALG2\'; %directory of TPWS files
tfName = 'G:\Harp_TF'; % Directory ...
% with .tf files (directory containing folders with different series ...
% Specify excel file with effort times
effortXls = 'C:\Users\HARP\Documents\MATLAB\Grateful-DetEdit\BW_Efforts.xls'; 
% !!! if not effort times: run groupID_noEffortTimes
refTime = '2008-01-01'; %reference time format 'yyyy-MM-dd' for SOCAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find TPWS folder names based on drive names provided
fk = 1; % folder counter
d = dir(tpwsPath);     % get directory list into structure d
ndl = length(d);    % number of files and folders
name = char(d.name);      % get name field of d structure
fileList = [];
for m = 3:ndl       % loop over file and folder names
    if regexp(name(m,:),project)
    fldn = fullfile(tpwsPath,strtrim(name(m,:)),'\TPWS');
    if itnum > 1 %% define subfolder that fit specified iteration
        for id = 2: str2num(itnum) % iternate id times according to itnum
            subfolder = ['\TPWS',num2str(id),'\'];
            fldn = (fullfile(fldn,subfolder));
        end
    end
    flName = [strtrim(name(m,:)),'_',sp,'_TPWS',itnum,'.mat']; %file name
    allFile = (fullfile(fldn,flName));
    fileList{fk} = cellstr(allFile);
    fk = fk + 1;
    end
end
nf = fk - 1;

%% Find all TPWS files that fit your specifications
% Get a list of all the files in the directories
% for k = 1:nf
%     fileList = cellstr(ls(fldrName{k}));
%     % Find the file name that matches the filePrefix
%     fileMatchIdx = find(~cellfun(@isempty,regexp(fileList,flName{k}))>0);
%     if isempty(fileMatchIdx)
%         % if no matches, throw error
%         disp('No files matching filePrefix found!')
%     end
% end
%% Get effort times matching prefix file
allEfforts = readtable(effortXls);
% site = strsplit(filePrefix,'_');
effTable = allEfforts(ismember(allEfforts.Sites,site),:);
% effTable = allEfforts(ismember(allEfforts.Deployments,site(2)),:);

% make Variable Names consistent
startVar = find(~cellfun(@isempty,regexp(effTable.Properties.VariableNames,'Start.*Effort'))>0,1,'first');
endVar = find(~cellfun(@isempty,regexp(effTable.Properties.VariableNames,'End.*Effort'))>0,1,'first');
effTable.Properties.VariableNames{startVar} = 'Start';
effTable.Properties.VariableNames{endVar} = 'End';

Start = datetime(x2mdate(effTable.Start),'ConvertFrom','datenum');
End = datetime(x2mdate(effTable.End),'ConvertFrom','datenum');
% Start = datetime(x2mdate(effTable.Start));
% End = datetime(x2mdate(effTable.End));

effort = timetable(Start,End);

%% Concatenate all detections from the same site and create the plots
% concatFiles = fileList;

% SumPPICIBin('filePrefix',filePrefix,'concatFiles', concatFiles,'sp', sp,...
%     'sdir', tpwsPath,'effort',effort,'referenceTime',refTime);
SumPPICIBin('filePrefix',filePrefix,'concatFiles',fileList,...
    'sp',sp,'sdir', tpwsPath,'effort',effort,'referenceTime',refTime);



disp('Done processing')