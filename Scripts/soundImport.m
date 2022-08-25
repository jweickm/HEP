% Written by Jakob Weickmann

function [attentionSounds] = soundImport()

    textprogressbar('Importing sound files: '); % initialize textprogressbar
    soundStimuli_dir = dir('./Sound_files/*.wav');
    
    % preallocate sounds struct
    attentionSounds = struct('y', zeros(length(soundStimuli_dir),1), 'freq', zeros(length(soundStimuli_dir),1));
    
    % read wavedata (first sound is for fixation cross)
    for i = 1:length(soundStimuli_dir)
        [attentionSounds(i).y, attentionSounds(i).freq] = psychwavread(strcat('./Sound_files/',soundStimuli_dir(i).name));
        textprogressbar(i * 100/length(soundStimuli_dir));
    end
    textprogressbar('done');
    
    % remove trailing zeros of wavedata files
    textprogressbar('Removing trailing 0''s: '); % initialize textprogressbar
    for w = 1:length(attentionSounds)
        attentionSounds(w).y = remTrailingZeros(attentionSounds(w).y);
        textprogressbar(w * 100/length(attentionSounds));
    end   
    textprogressbar('done');

    % convert to stereo
    attentionSounds = convert2stereo(attentionSounds);
    
    % flip wavedata matrix to work with PsychSound
    textprogressbar('Flipping Sound Matrix: ');
    for s = 1:length(attentionSounds)
        attentionSounds(s).y_ = attentionSounds(s).y';
        textprogressbar(s * 100/length(attentionSounds));
    end
    textprogressbar('done');
    
    % Save auditive stimuli in mat file
    textprogressbar('Saving sounds to .mat: ');
    save('./Stimuli/sounds.mat', 'attentionSounds');
    textprogressbar(100);
    textprogressbar('done');
return