% HEP_Experiment(screenNumber, SkipTests, uniqueSourceID, Fullscreen, stimulusSounds)
% This script presents different facial stimuli to be used with heartbeat evoked potentials
% written by Jakob Weickmann, MA BSc
% Github: https://github.com/wunderwald/MindTheBody/tree/Jakob/HEP

% Warning! Make sure that the folder structure is exactly the same as on
% Github. Load the visual stimuli as well as the sounds manually. Make sure
% that there is the same number of images in each category (emotion * sex).

function HEP_Experiment(screenNumber, SkipTests, uniqueSourceID, Fullscreen, stimulusSounds)

%% ===================================================
%               INITIALIZATION AND DEFAULTS
% ==========================================================

% Clear everything
close all;
clear mem;
sca;
clc;

disp('Initializing script...');

origin_folder = cd;
addpath 'Scripts';
pathToMatlabImporter = 'C:\Program Files\MATLAB\MATLABImporter';
pathToMatlabViewer = 'C:\Program Files\MATLAB\MATLABViewer';

if nargin < 1
    % Get the screen numbers. This gives us a number for each of the screens
    % attached to our computer (only 1 screen? this will be 0).
    screens = Screen('Screens');
    % screenNumber = max(screens);
    screenNumber = 3;
end
if nargin < 2
    SkipTests = 1;
end
if nargin < 3
    uniqueSourceID = 'Mangold PC';
end
if nargin < 4
    Fullscreen = 1;
end
if nargin < 5
    stimulusSounds = 0;
end

%% ===================================================
%                   EXPERIMENTAL DESIGN
% ==========================================================

nTrials = 48; % number of trials per block
nBlocks = 2; % number of experimental blocks
nEmotions = 3; % 1 Happy, 2 Neutral, 3 Angry
nSounds = 8; % types of sounds for stimuli (excluding the one for the fixation cross)
nPeople = 16; % number of different actors for facial stimuli

% Durations in seconds
durations = [2.000 ... % inter-trial interval (baby)
             1.000 ... % inter-trial interval (mother)
             0.500 ... % jitter
             1.000 ... % fixation cross
             3.000 ... % stimulus
             0.400  ]; % interval between fix and stimulus

% Background Colour when opening window
bgc = 216;

%% ===================================================
%                 LAB STREAMING LAYER (LSL)
% ==========================================================

textprogressbar('Initializing LSL:  ');
% uses the paths that are set in the beginning of the script
addpath(pathToMatlabImporter);
addpath(genpath(pathToMatlabViewer));

% instantiate the library
% disp('Loading library...');
lib = lsl_loadlib();
textprogressbar(33);

% make a new stream outlet

% disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'HEP Trigger Stream','Markers',1,0,'cf_string', uniqueSourceID);
textprogressbar(66);

% disp('Opening an outlet...');
outlet = lsl_outlet(info);
textprogressbar(100);
textprogressbar('done');

% send markers into the outlet
disp('Marker stream successfully initiated.');
fprintf('Now streaming data...\n\n');

%% ===================================================
%               PARTICIPANT'S DETAILS DIALOG
% ==========================================================

prompt = 'Please enter the participant ID (integer)\n';
subjectCode = [];
yes = ["y", "Y", "yes", "Yes", "YES", "absolutely"];

while true
        try subjectCode = input(prompt);
            subjectString = strcat('./Output/Subject_', sprintf('%02s', num2str(subjectCode)), '.mat'); % to pad the subjectCode with zeroes if necessary
            if exist(subjectString, 'file')
                disp('This subject ID already exists.');
                if ismember(input('Do you really want to continue? (Y/N)\n', 's'), yes)
                    break;
                else
                    subjectCode = [];
                    continue;
                end
            end
            fprintf('The participant ID is %d.\n', subjectCode);
            if ismember(input('Is that correct? (Y/N)\n', 's'), yes)
                break;
            else
                subjectCode = [];
            end
        catch
            warning('ID must be an integer.');
        end
end

%% ===================================================
%                       SCREEN SETUP
% ==========================================================

% Fullscreen
if Fullscreen
    screenRect = [];
else
    screenRect = [10 10 710 710];
end

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
% white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

%% ===================================================
%                   LOAD VISUAL STIMULI
% ==========================================================

% if no preloaded stimuli already exist in the folder
if ~exist('./Stimuli/images.mat', 'file')
    [facialStimuli] = imageImport('separateFolders');
else
    disp('images.mat found');
    textprogressbar('Loading images:        ');
    load('./Stimuli/images.mat', 'facialStimuli');
    try
        textprogressbar(100);
    catch
        textprogressbar('Loading images:        ');
        textprogressbar(100);
    end
    textprogressbar('done');
end

%% ===================================================
%                       LOAD SOUNDS
% ==========================================================

% Read WAV file from filesystem:
% if no preloaded stimuli already exist in ./Stimuli
if ~exist('./Stimuli/sounds.mat', 'file')
    attentionSounds = soundImport;
else
    disp('sounds.mat found');
    textprogressbar('Loading sounds:        ');
    load('./Stimuli/sounds.mat', 'attentionSounds');
    try
        textprogressbar(100);
    catch
        textprogressbar('Loading sounds:        ');
        textprogressbar(100);
    end
    textprogressbar('done');
end

%% ===================================================
%                        TRIAL MATRIX
% ==========================================================

% create a trial matrix from which to select on each trial
% generate Trial Matrix with the function "makeSequence.m"
% credit to Moritz Wunderwald

TrialMat = makeTrialMat(nTrials, nBlocks, nEmotions, nPeople, nSounds);

%% ===================================================
%                     OPEN ON-SCREEN WINDOW
% ==========================================================

disp('Opening on-screen window...');

% using Screen
bgColour_RGB = bgc * ones(1,3); % RGB
[windowPtr, windowRect] = Screen('OpenWindow', screenNumber, bgColour_RGB, screenRect);

% using Psychimaging
% bgColour = bgc/255; % 0 - 1
% [windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, bgColour, screenRect);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(windowPtr);

% set priority level for accurate timing
Priority(topPriorityLevel);

%% ===================================================
%       EXPERIMENT PARAMETERS: TEXT, STIMULI, DURATIONS
% ==========================================================

textprogressbar('Setting up screen: ');

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', windowPtr);

% durations in frames: dividing by ifi
iDur      = round(durations(1)/ifi); % numbers are in seconds
iDurAdult = round(durations(2)/ifi);
jitter    = round(durations(3)/ifi);
fDur      = round(durations(4)/ifi);
stDur     = round(durations(5)/ifi);
mDur      = round(durations(6)/ifi);

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

%% ---------------------------------------------------
%                          FIXATION CROSS
% ----------------------------------------------------------

% (See https://peterscarfe.com/fixationcrossdemo.html)

% Set the radius of the fixation cross
fixRadius = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixRadius fixRadius 0 0];
yCoords = [0 0 -fixRadius fixRadius];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

textprogressbar(100);
textprogressbar('done');

%% ---------------------------------------------------
%                  PREALLOCATING VARIABLES
% ----------------------------------------------------------

% preallocate condition variables
trialEmotion  = zeros(nTrials, nBlocks);
trialSound    = zeros(nTrials, nBlocks);
trialPerson   = zeros(nTrials, nBlocks);
invalidTrials = zeros(nTrials, nBlocks);
timings       = zeros(nTrials, 4, nBlocks);

%% ---------------------------------------------------
%                              KEYS
% ----------------------------------------------------------

% provide a consistent mapping of keyCodes to key names on all operating systems.
KbName('UnifyKeyNames');

% keyCodes: [Space, Return, Escape, G, H, X, P]
abortExpKey = 'Escape';
attentionGrabberKey = 'G';
pauseKey = 'P';
abortBlockKey = 'X';
keyCodes = [KbName('Space'), KbName('Return'), KbName(abortExpKey), ...
    KbName(attentionGrabberKey), KbName(attentionGrabberKey) + 1, ...
    KbName(abortBlockKey), KbName(pauseKey)];
RestrictKeysForKbCheck(keyCodes);

%% ---------------------------------------------------
%                         AUDIO PLAYBACK
% ----------------------------------------------------------

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

%% *            GERMAN INSTRUCTIONS                 *
% ==========================================================

waitText = ['Bitte warten Sie auf Anweisung \ndurch die '...
    'Versuchsleitung.'];
instrText = ['Nehmen Sie eine entspannte Sitzhaltung ein und \nbetrachten Sie die Bilder auf dem Monitor.\n\n'...
    'Bitte interagieren Sie dabei nicht mit Ihrem Baby.'];
pauseText = 'Kurze Pause';


%% **************************************************
%  |                   WELCOME SCREEN                     |
%  ********************************************************

ListenChar(2); % suppress listening to Matlab
HideCursor(screenNumber); % hide cursor

Screen('Preference','TextEncodingLocale', 'UTF-8');
Screen('TextFont', windowPtr, 'Calibri');
Screen('TextSize', windowPtr, 44);

% Display message
DrawFormattedText(windowPtr, uint8(waitText), 'center', 'center', 0, 77);
Screen('Flip', windowPtr);
disp('Press SPACEBAR or ENTER to continue.');
KbWait();

% display instructions before 1st block
DrawFormattedText(windowPtr, uint8(instrText), 'center', 'center', 0, 77);
Screen('Flip', windowPtr);

disp('Press SPACEBAR or ENTER to continue.');
WaitSecs(1);
KbWait();

fprintf('\nExperiment is about to begin.\n\n');
DrawFormattedText(windowPtr, uint8('Das Experiment beginnt '), 'center', 'center', 0, 77);
Screen('Flip', windowPtr);
WaitSecs(0.5);

disp('Experiment begins in 3...');
DrawFormattedText(windowPtr, uint8('Das Experiment beginnt .'), 'center', 'center', 0, 77);
Screen('Flip', windowPtr);
WaitSecs(0.5);
disp('                     2...');
DrawFormattedText(windowPtr, uint8('Das Experiment beginnt ..'), 'center', 'center', 0, 77);
Screen('Flip', windowPtr);
WaitSecs(0.5);
disp('                     1...');
DrawFormattedText(windowPtr, uint8('Das Experiment beginnt ...'), 'center', 'center', 0, 77);
Screen('Flip', windowPtr);
WaitSecs(0.5);
disp('-------------------------');

%% ===================================================
%                 EXPERIMENTAL LOOP (BLOCKS)
% ==========================================================

startTime = clock();

for b = 1:nBlocks
    if b ~= 1
        iDur = iDurAdult;
        DrawFormattedText(windowPtr, uint8(strcat(sprintf('Ende von Block %d\n%s',b,pauseText))), 'center', 'center', 0, 77);
        Screen('Flip', windowPtr);
        WaitSecs(1);
        KbWait();
    end
    fprintf('Current Block: %d of %d\n', b, nBlocks);
    textprogressbar('Running Block:         ');

    % Wait for release of all keys on keyboard:
    KbReleaseWait;
    outlet.push_sample({['Block ', num2str(b), ' start']});

    %% ===================================================
    %                       TRIAL LOOP
    % ==========================================================

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

        %% ---------------------------------------------------
        %                   INTERVAL (Inter Trial)
        % -----------------------------------------------------------

        % Fill the audio playback buffer with the audio data 'wavedata':
        % for fixation cross
        PsychPortAudio('FillBuffer', pahandle, attentionSounds(1).y_);

        intervalJitter = randi(2*jitter)+ iDur-jitter-1;
        for i = 1:intervalJitter % for inter trial interval
            Screen('Flip', windowPtr); % initial flip

            % check for breakKeys (Esc to end to programm, G for attention getter)
            [skipTrial, skipBlock, terminate] = reactToKeyPresses(pahandle, keyCodes, windowPtr, windowRect, skipTrial, outlet, origin_folder, Fullscreen);
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

        %% ---------------------------------------------------
        %                      FIXATION CROSS
        % -----------------------------------------------------------

        % Draw the fixation cross in white, set it to the center of screen
        Screen('DrawLines', windowPtr, allCoords, lineWidthPix, black, [xCenter yCenter]);
        outlet.push_sample({'fixation cross on'});

        % Play fix cross sound
        PsychPortAudio('Start', pahandle);
        timings(t, 1, b) = etime(clock, startTime);
        Screen('Flip', windowPtr); % fixation cross on

        for i = 1:(fDur-1)
            Screen('DrawLines', windowPtr, allCoords, lineWidthPix, black, [xCenter yCenter]);
            Screen('Flip', windowPtr);

            % check for breakKeys (Esc to end to programm, G for attention getter)
            [skipTrial, skipBlock, terminate] = reactToKeyPresses(pahandle, keyCodes, windowPtr, windowRect, skipTrial, outlet, origin_folder, Fullscreen);
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
        PsychPortAudio('Stop', pahandle);

        timings(t, 2, b) = etime(clock, startTime); % fixation cross off
        outlet.push_sample({'fixation cross off'});

        %% ---------------------------------------------------
        %           INTERVAL (Fixation Cross -> Stimulus)
        % -----------------------------------------------------------

        if stimulusSounds
            % Fill the audio playback buffer with the audio data 'wavedata':
            PsychPortAudio('FillBuffer', pahandle, attentionSounds(trialSound(t,b)).y_);
        end

        currentTexture = Screen('MakeTexture', windowPtr, stimulus);

        % Interval between fixation cross and stimulus
        for i = 1:mDur
            Screen('Flip', windowPtr);

            % check for breakKeys (Esc to end to programm, G for attention getter)
            [skipTrial, skipBlock, terminate] = reactToKeyPresses(pahandle, keyCodes, windowPtr, windowRect, skipTrial, outlet, origin_folder, Fullscreen);
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

        %% ---------------------------------------------------
        %                            STIMULUS
        % -----------------------------------------------------------

        % Draw stimulus on screen
        Screen('DrawTexture', windowPtr, currentTexture, sourceRect, stimulusRect_Center);

        outlet.push_sample({strcat('Emotion: ',num2emo(trialEmotion(t,b)),' Person: ', num2str(trialPerson(t,b)), ' face on')});

        if stimulusSounds
            % play corresponding sound
            PsychPortAudio('Start', pahandle);
        end

        % Flip to screen
        timings(t, 3, b) = etime(clock, startTime);

        for i = 1:(stDur-1)
            Screen('DrawTexture', windowPtr, currentTexture, sourceRect, stimulusRect_Center);
            Screen('Flip', windowPtr);

            % check for breakKeys (Esc to end to programm, G for attention getter, H to terminate)
            [skipTrial, skipBlock, terminate] = reactToKeyPresses(pahandle, keyCodes, windowPtr, windowRect, skipTrial, outlet, origin_folder, Fullscreen);
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

        if stimulusSounds
            % Stop Audio Playback
            PsychPortAudio('Stop', pahandle);
        end
        t = t + 1;
    end
    if ~skipBlock
        textprogressbar('Block completed');
    else
        textprogressbar('Block aborted');
    end
end

%% ===================================================
%                       SAVE AND EXIT
% ==========================================================

disp('Saving up and closing');
exit_routine(subjectCode, origin_folder, outlet, TrialMat, invalidTrials, stimulusSounds, uniqueSourceID, timings);
return
