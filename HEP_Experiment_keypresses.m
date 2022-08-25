% HEP_Experiment(SkipTests,Fullscreen,Smarting,stimulusSounds,screenNumber,uniqueSourceID,attentionGetterKey)
% This script presents different facial stimuli to be used with heartbeat evoked potentials
% written by Jakob Weickmann, MA BSc
% Github: https://github.com/wunderwald/MindTheBody/tree/Jakob/HEP

% Warning! Make sure that the folder structure is exactly the same as on
% Github. Load the visual stimuli as well as the sounds manually. Make sure
% that there is the same number of images in each category (emotion * sex).

function HEP_Experiment(SkipTests, Fullscreen, Smarting, stimulusSounds, screenNumber, uniqueSourceID, attentionGetterKey)

%% Setup
% Clear everything
close all;
clear mem;
sca;
clc;
origin_folder = cd;
addpath 'Scripts';
pathToMatlabImporter = 'C:\Program Files\MATLAB\MATLABImporter';
pathToMatlabViewer = 'C:\Program Files\MATLAB\MATLABViewer';

if nargin < 1
    SkipTests = 0;
end
if nargin < 2
    Fullscreen = 1;
end
if nargin < 3
    Smarting = 1;
end
if nargin < 4
    stimulusSounds = 0;
end
% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer (only 1 screen? this will be 0).
screens = Screen('Screens');

if nargin < 5
    % To draw we select the maximum of these numbers. So in a situation where we
    % have two screens attached to our monitor we will draw to the external
    % screen.
    screenNumber = max(screens);
    % screenNumber = min(screens);
end
if nargin < 6
    uniqueSourceID = 'Mangold PC';
end
if nargin < 7
    attentionGetterKey = 'G';
end

% Fullscreen
if Fullscreen
    screenRect = [];
else
    screenRect = [10 10 710 710];
end

%% Experimental Design
nTrials = 48; % number of trials per block
nBlocks = 2; % number of experimental blocks

% types of emotions
nEmotions = 3; % Happy, Neutral, Angry
% types of sounds for stimuli (excluding the one for the fixation cross)
nSounds = 8;
% number of people (that make stimuli)
nPeople = 16;

%% Enter Participant's Details
prompt = 'Please enter the participant ID (integer)\n';
subjectCode = [];
yes = ["y", "Y", "yes", "Yes", "YES", "absolutely"];
while isempty(subjectCode)
        try subjectCode = input(prompt);
        catch
            warning('ID must be an integer.');
        end
        subjectString = strcat('./Output/Subject_', sprintf('%02s', num2str(subjectCode)), '.mat'); % to pad the subjectCode with zeroes if necessary
        if exist(subjectString, 'file')
            disp('This subject ID already exists.');
            if ismember(input('Do you really want to continue? (Y/N)\n', 's'), yes)
                break;
            else
                subjectCode = [];
            end
        end
end

%% Screen Setup
disp('Initializing script...');

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
rng('shuffle');

% disable syn tests when coding/debugging but not when running ex periments!!
if SkipTests
    Screen('Preference', 'SkipSyncTests', 1);
else
    Screen('Preference', 'SkipSyncTests', 0);
end

% Checking Psychtoolbox: Break and issue an eror message if installed
% Psychtoolbox is not based on OpenGL or Screen() is not working properly.
AssertOpenGL;

% Get black and white for your system.
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Get medium gray.
gray = (white-black)/2;

% Define background color when opening window.
bgColour = 216/255;
bgColour_RGB = [216 216 216];

%% Load visual stimuli
% if no preloaded stimuli already exist in the folder
if ~exist('./Variables/stimuli.mat', 'file')
    [facialStimuli, nFaces] = imageImport('separateFolders');
else
    disp('stimuli.mat found');
    textprogressbar('Loading images:        ');
    load('./Variables/stimuli.mat', 'facialStimuli', 'nFaces');
    try
        textprogressbar(100);
    catch 
        textprogressbar('Loading images:        ');
        textprogressbar(100);
    end
    textprogressbar('done');
end

%% Load sound stimuli
% refer to
% https://github.com/Psychtoolbox-3/Psychtoolbox-3/blob/master/Psychtoolbox/PsychDemos/BasicSoundOutputDemo.m
% Running on PTB-3? Abort otherwise.
AssertOpenGL;

% Read WAV file from filesystem:
% if no preloaded stimuli already exist in ./Variables
if ~exist('./Variables/sounds.mat', 'file')
    attentionSounds = soundImport;
else
    disp('sounds.mat found');
    textprogressbar('Loading sounds:        ');
    load('./Variables/sounds.mat', 'attentionSounds');
    try
        textprogressbar(100);
    catch
        textprogressbar('Loading sounds:        ');
        textprogressbar(100);
    end
    textprogressbar('done');
end

%% Trial Matrix
% create a trial matrix from which to select on each trial
% generate Trial Matrix with the function "makeSequence.m"
% credit to Moritz Wunderwald

TrialMat = makeTrialMat(nTrials, nBlocks, nEmotions, nPeople, nSounds);

%% Key Mapping Setup, ListenChar, HideCursor
% provide a consistent mapping of keyCodes to key names on all operating systems.
KbName('UnifyKeyNames');
HideCursor(screenNumber);

%% Open on-screen window
% [windowPtr, windowRect] = Screen('OpenWindow', screenNumber, bgColour);
% Open a fullscreen window using Screen('OpenWindow'). This returns a
% window handle (windowPtr) and the coordinates of the window
% (windowRectrect).
disp('Opening on-screen window...');

 [windowPtr, windowRect] = Screen('OpenWindow', screenNumber, bgColour_RGB, screenRect);
% [windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, bgColour, screenRect);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(windowPtr);

% set priority level for accurate timing
Priority(topPriorityLevel);

%% Experiment Parameters: Text, Stimuli, Durations
textprogressbar('Setting up screen: ');

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', windowPtr);

% durations in frames
fDur  = round(1.000/ifi); % numbers are in seconds
stDur = round(3.000/ifi);
mDur  = round(0.400/ifi);

% intertrial interval with jitter
iDur  = round(2.000/ifi);
jitter = round(0.500/ifi);
iDurAdult = round(1.000/ifi);

% durations in seconds
fixDur               = ifi * (fDur-0.5); % duration of fixation point
stimulusDur          = ifi * (stDur-0.5); % stimulus duration (face)
maskDur              = ifi * (mDur-0.5); % masking duration
iti                  = ifi * (iDur-0.5); % inter trial interval

% location coordinates (rects)
% center coordinates
[xCenter, yCenter] = RectCenter(windowRect);

% stimulus sizes in pixels
stimulusRadius = yCenter - 0.10 * yCenter;
sourceRect = [110, 50, 580, 740]; % this part of the image will be shown...
ratio = (sourceRect(4)-sourceRect(2))/(sourceRect(3)-sourceRect(1));

% ratio = 1.50367107195301; % this is the original image ratio

% in this target area
stimulusRect_Center = [xCenter - (stimulusRadius/ratio), yCenter - (stimulusRadius),...
                     xCenter + (stimulusRadius/ratio), yCenter + (stimulusRadius)];

try
    textprogressbar(50);
catch
    textprogressbar('Setting up screen: ');
    textprogressbar(50);
end

%% Fixation Cross
% (See https://peterscarfe.com/fixationcrossdemo.html)

% Set the radius of the fixation cross
fixRadius = 40;

% coordinate rects
fixRect =           [xCenter - fixRadius, yCenter - fixRadius,...
                     xCenter + fixRadius, yCenter + fixRadius];

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixRadius fixRadius 0 0];
yCoords = [0 0 -fixRadius fixRadius];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

textprogressbar(100);
textprogressbar('done');

%% INSTRUCTIONS
instrText = ['Nehmen Sie eine entspannte Sitzhaltung ein und betrachten Sie die Bilder auf dem Monitor.\n\n'...
    'Bitte interagieren Sie dabei nicht mit Ihrem Baby.'];

%% Preallocate variables that will change/append in every loop
% preallocate condition variables
trialEmotion  = zeros(nTrials, nBlocks);
trialSound    = zeros(nTrials, nBlocks);
trialPerson   = zeros(nTrials, nBlocks);
invalidTrials = zeros(nTrials, nBlocks);
timings       = zeros(nTrials, 4, nBlocks);

%% Keys
keyCodes = [KbName('Space'), KbName('Return'), KbName('Escape'), KbName(attentionGetterKey), KbName(attentionGetterKey) + 1, KbName('X')];
oldenablekeys = RestrictKeysForKbCheck(keyCodes);

%% Audio Playback
% Perform basic initialization of the sound driver:
disp('Initializing PsychSound: ');
InitializePsychSound;

% can specify audio device here
device = [];

% Open the  audio device, with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
disp('Trying to open audio device...');
try
    % Try with the 'freq'uency we wanted:
    pahandle = PsychPortAudio('Open', device, [], 0, attentionSounds(1).freq, 2);
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq);
    fprintf('Sound may sound a bit out of tune, ...\n\n');
    psychlasterror('reset');
    pahandle = PsychPortAudio('Open', device, [], 0, [], 2);
end

%% LAB Streaming Layer (LSL)
textprogressbar('Initializing LSL:  ');
% uses the paths that are set in the beginning of the script
addpath(pathToMatlabImporter);
addpath(genpath(pathToMatlabViewer));

% instantiate the library
% disp('Loading library...');
lib = lsl_loadlib();
textprogressbar(33);

% make a new stream outlet
% the name (here MyMarkerStream) is visible to the experimenter and should be chosen so that
% it is clearly recognizable as your MATLAB software's marker stream
% The content-type should be Markers by convention, and the next three arguments indicate the
% data format (1 channel, irregular rate, string-formatted).
% The so-called source id is an optional string that allows for uniquely identifying your
% marker stream across re-starts (or crashes) of your script (i.e., after a crash of your script
% other programs could continue to record from the stream with only a minor interruption).

% disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'HEP Trigger Stream','Markers',1,0,'cf_string',uniqueSourceID);
textprogressbar(66);

% disp('Opening an outlet...');
outlet = lsl_outlet(info);
textprogressbar(100);
textprogressbar('done');

% send markers into the outlet
disp('Marker stream successfully initiated.');
h = actxserver('WScript.Shell'); % for sending keypresses
ListenChar(2); % suppress listening to Matlab
disp('Now streaming data...');

%% Welcome Screen
Screen('Preference','TextEncodingLocale', 'UTF-8');
Screen('TextFont', windowPtr, 'Calibri');
Screen('TextSize', windowPtr, 44);
% Display message
DrawFormattedText(windowPtr, ['Bitte warten Sie auf Anweisung \ndurch die '...
    'Versuchsleitung.'], 'center', 'center', 0, 77);
Screen('Flip', windowPtr);
disp('Press SPACEBAR or ENTER to continue.');
KbWait();

fprintf('\nExperiment is about to begin.\n\n');
WaitSecs(0.5);

disp('Experiment begins in 3...');
WaitSecs(0.5);
disp('                     2...');
WaitSecs(0.5);
disp('                     1...');
WaitSecs(0.5);
disp('-------------------------');

% Try to bring Signal Display Window into Focus
if Smarting
    try
        h.AppActivate('Signal display');
    catch
        disp('Could not find Smarting Signal Display.');
    end
end

%% Experimental Loop (Blocks)
% display instructions before 1st block
DrawFormattedText(windowPtr, uint8(instrText), 'center', 'center', 0, 77);
Screen('Flip', windowPtr);
KbWait();

disp('Press SPACEBAR or ENTER to continue.');
WaitSecs(1);
KbWait();
startTime = clock();

for b = 1:nBlocks
    if b ~= 1
        iDur = iDurAdult;
        DrawFormattedText(windowPtr, 'Time to take a short break', 'center', 'center', 0, 77);
        Screen('Flip', windowPtr);
        WaitSecs(1);
        KbWait();
    end
    fprintf('Current Block: %d of %d\n', b, nBlocks);
    textprogressbar('Running Block:         ');
    
    % Wait for release of all keys on keyboard:
    KbReleaseWait;
    outlet.push_sample({['Block ', num2str(b), ' start']});
    h.SendKeys('b');
    

    %% TRIAL Loop
    t = 1;
    skipBlock = 0;
    while t <= nTrials
        if skipBlock
            break;
        end
        textprogressbar(t * 100/nTrials);
        skipTrial = 0;

        % select each condition from the trial matrix
        trialEmotion(t,b) = TrialMat(2,t,b);
        trialPerson(t,b)  = TrialMat(3,t,b);
        trialSound(t,b)   = TrialMat(4,t,b);

        % prepare image for presentation
        stimulusEmotion = facialStimuli(:,:,trialEmotion(t,b));
        stimulus = stimulusEmotion{trialPerson(t,b)};

       %% Inter Trial Interval
        % Fill the audio playback buffer with the audio data 'wavedata':
        % for fixation cross
        PsychPortAudio('FillBuffer', pahandle, attentionSounds(1).y_);

        intervalJitter = randi(2*jitter)+ iDur-jitter-1;
        for i = 1:intervalJitter % for inter trial interval
            Screen('Flip', windowPtr); % initial flip

            % check for breakKeys (Esc to end to programm, G for attention getter)
            [skipTrial, skipBlock, terminate] = reactToKeyPresses(pahandle, attentionGetterKey, windowPtr, windowRect, skipTrial, outlet, origin_folder, Fullscreen);
            if skipTrial
                break;
            elseif terminate
                exit_routine(subjectCode, origin_folder, outlet, TrialMat, invalidTrials, stimulusSounds, uniqueSourceID, timings);
                return
            end
        end
        if skipTrial

            continue;
        end

       %% Fixation Cross
        % Draw the fixation cross in white, set it to the center of screen
        Screen('DrawLines', windowPtr, allCoords, lineWidthPix, black, [xCenter yCenter]);
        outlet.push_sample({'fixation cross on'});
        h.SendKeys('f');

        % Play fix cross sound
        tFixOn = PsychPortAudio('Start', pahandle);
        timings(t, 1, b) = etime(clock, startTime);
        Screen('Flip', windowPtr); % fixation cross on

        for i = 1:(fDur-1)
            Screen('DrawLines', windowPtr, allCoords, lineWidthPix, black, [xCenter yCenter]);
            Screen('Flip', windowPtr);

            % check for breakKeys (Esc to end to programm, G for attention getter)
            [skipTrial, skipBlock, terminate] = reactToKeyPresses(pahandle, attentionGetterKey, windowPtr, windowRect, skipTrial, outlet, origin_folder, Fullscreen);
            if skipTrial
                break;
            elseif terminate
                exit_routine(subjectCode, origin_folder, outlet, TrialMat, invalidTrials, stimulusSounds, uniqueSourceID, timings);
                return
            end
        end
        if skipTrial
            continue;
        end

        % Stop Audio Playback
        tFixOff = PsychPortAudio('Stop', pahandle);

        timings(t, 2, b) = etime(clock, startTime); % fixation cross off
        outlet.push_sample({'fixation cross off'});
        h.SendKeys('c');


       %% Inter fixation cross - stimulus interval
        if stimulusSounds
            % Fill the audio playback buffer with the audio data 'wavedata':
            PsychPortAudio('FillBuffer', pahandle, attentionSounds(trialSound(t,b)).y_);
        end

        currentTexture = Screen('MakeTexture', windowPtr, stimulus);

        % Interval between fixation cross and stimulus
        for i = 1:mDur
            Screen('Flip', windowPtr);

            % check for breakKeys (Esc to end to programm, G for attention getter)
            [skipTrial, skipBlock, terminate] = reactToKeyPresses(pahandle, attentionGetterKey, windowPtr, windowRect, skipTrial, outlet, origin_folder, Fullscreen);
            if skipTrial
                break;
            elseif terminate
                exit_routine(subjectCode, origin_folder, outlet, TrialMat, invalidTrials, stimulusSounds, uniqueSourceID, timings);
                return
            end
        end
        if skipTrial
            continue;
        end

        %% Stimulus Presentation
        % Draw stimulus on screen
        Screen('DrawTexture', windowPtr, currentTexture, sourceRect, stimulusRect_Center);
       
        outlet.push_sample({strcat('Emotion: ',num2emo(trialEmotion(t,b)),' Person: ', num2str(trialPerson(t,b)), ' face on')});
        h.SendKeys('s');

        if stimulusSounds
            % play corresponding sound
            tStimOn = PsychPortAudio('Start', pahandle);
        end
        
        % Flip to screen
        timings(t, 3, b) = etime(clock, startTime);

        for i = 1:(stDur-1)
            Screen('DrawTexture', windowPtr, currentTexture, sourceRect, stimulusRect_Center);
            Screen('Flip', windowPtr);

            % check for breakKeys (Esc to end to programm, G for attention getter, H to terminate)
            [skipTrial, skipBlock, terminate] = reactToKeyPresses(pahandle, attentionGetterKey, windowPtr, windowRect, skipTrial, outlet, origin_folder, Fullscreen);
            if skipTrial
                invalidTrials(t,b) = 1;
                t = t + 1;
                break;
            elseif terminate
                exit_routine(subjectCode, origin_folder, outlet, TrialMat, invalidTrials, stimulusSounds, uniqueSourceID, timings);
                return
            end
        end
        if skipTrial
            continue;
        end
        Screen('Close', currentTexture);

        timings(t, 4, b) = etime(clock, startTime);
        outlet.push_sample({strcat('Emotion: ',num2emo(trialEmotion(t,b)),' Person: ', num2str(trialPerson(t,b)), ' face off')});
        h.SendKeys('r');

        if stimulusSounds
            % Stop Audio Playback
            tStimOff = PsychPortAudio('Stop', pahandle);
        end
        t = t + 1;
    end
    if ~skipBlock
        textprogressbar('Block completed');
    else
        textprogressbar('Block aborted');
    end
end

%% Save and close up shop
disp('Saving up and closing');
exit_routine(subjectCode, origin_folder, outlet, TrialMat, invalidTrials, stimulusSounds, uniqueSourceID, timings);
return
