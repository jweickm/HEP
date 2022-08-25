% Written by Jakob Weickmann

function[skipTrial, skipBlock, terminate] = reactToKeyPresses(pahandle, keyCodes, windowPtr, windowRect, skipTrial, outlet, origin_folder, Fullscreen)
% check for breakKeys (Esc to end to programm, G for attention grabber, X to abort block, P to pause)
    [~, secs, keyCode] = KbCheck();
    terminate = 0;
    skipBlock = 0;
    if find(keyCode) == keyCodes(3) % abort exp key ('Escape')
        % Stop Audio Playback
        PsychPortAudio('Stop', pahandle);
        textprogressbar('aborted by user');
        outlet.push_sample({'aborted'});
        terminate = 1;
        return;
    elseif find(keyCode) == keyCodes(4) % attention grabber key ('G')
        % Stop Audio Playback
        PsychPortAudio('Stop', pahandle);
        outlet.push_sample({'attention getter on'});
        attentionGetterPlayback(windowPtr, windowRect, secs, origin_folder, Fullscreen);
        outlet.push_sample({'attention getter off'});
        skipTrial = 1;
    elseif find(keyCode) == keyCodes(6) % abort block key ('X')
        % Skip to second block
        outlet.push_sample({'Block aborted'});
        skipTrial = 1;
        skipBlock = 1;
    elseif find(keyCode) == keyCodes(7) % pause key ('P')
        % wait 
        outlet.push_sample({'Script Paused'});
        WaitSecs(1);
        KbWait();
        WaitSecs(0.2);
        outlet.push_sample({'Script Unpaused'});
    end
return