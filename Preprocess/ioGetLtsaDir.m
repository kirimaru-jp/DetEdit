function ioGetLtsaDir
%get_ltsadir get directory of wave/xwav files 
%
% Prompt user to enter a directory path containg audio files, and specify  
% audio format.
%
% Copyright(C) 2018 by John A. Hildebrand, UCSD, jahildebrand@ucsd.edu
%                      Kait E. Frasier, UCSD, krasier@ucsd.edu
%                      Alba Solsona Berga, UCSD, asolsonaberga@ucsd.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the file type
%
prompt={'Enter File Type: (1 = WAVE, 2 = XWAV)'};
def={num2str(PARAMS.ltsa.ftype)};
dlgTitle='Select File Type';
lineNo=1;
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
% display input dialog box window
in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
if isempty(in)	% if cancel button pushed
    PARAMS.ltsa.gen = 0;
    return
else
    PARAMS.ltsa.gen = 1;
end
PARAMS.ltsa.ftype = str2double(deal(in{1}));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the directory
%
if PARAMS.ltsa.ftype == 1
    str1 = 'Select Directory with WAV files';
elseif PARAMS.ltsa.ftype == 2
    str1 = 'Select Directory with XWAV files';
else
    disp('Wrong file type. Input 1 or 2 only')
    disp(['Not ',num2str(PARAMS.ltsa.ftype)])
    get_ltsadir
end
ipnamesave = PARAMS.ltsa.indir;
PARAMS.ltsa.indir = uigetdir(PARAMS.ltsa.indir,str1);
if PARAMS.ltsa.indir == 0	% if cancel button pushed
    PARAMS.ltsa.gen = 0;
    PARAMS.ltsa.indir = ipnamesave;
    return
else
    PARAMS.ltsa.gen = 1;
    PARAMS.ltsa.indir = [PARAMS.ltsa.indir,'\'];
end

%%%%%%%%%%%%%%%%%%%%%%
% check for empty directory
%
if PARAMS.ltsa.ftype == 1
    d = dir(fullfile(PARAMS.ltsa.indir,'*.wav'));    % wav files
elseif PARAMS.ltsa.ftype == 2
    d = dir(fullfile(PARAMS.ltsa.indir,'*.x.wav'));    % xwav files
end

fn = char(d.name);      % file names in directory
fnsz = size(fn);        % number of data files in directory
nfiles = fnsz(1);
disp([num2str(nfiles),' data files for LTSA'])
if fnsz(2)>80
    disp('Error: filename length too long')
    disp('Rename to 80 characters or less')
    disp('Abort LTSA generation')
    return
end

if nfiles < 1
    disp(['No data files in this directory: ',PARAMS.ltsa.indir])
    disp('Pick another directory')
    ioGetLtsaDir
end

if PARAMS.ltsa.ftype == 1
    % sort filenames into ascending order based on time stamp of file name
    % don't rely on filename only for order
    % timing stuff:
    dnums = wavname2dnum(fn);
    if isempty(dnums)
        dnumStart = datenum([0 1 1 0 0 0]);
    else
        dnumStart = dnums - datenum([2000 0 0 0 0 0]);
    end    
   
    % sort times
    [~,index] = sortrows(dnumStart');
    % put file name in PARAMS
    PARAMS.ltsa.fname = fn(index,:);
elseif PARAMS.ltsa.ftype == 2
    % filenames
    PARAMS.ltsa.fname = fn;
end

