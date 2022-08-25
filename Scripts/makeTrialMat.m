% Written by Jakob Weickmann
% Make TrialMatrix

function[TrialMat] = makeTrialMat(nTrials, nBlocks, nEmotions, nPeople, nSound)
    nSoundGroups = round(nTrials/nSound);
    TrialMat = zeros(4,nTrials,nBlocks); % preallocate Trial Matrix

    textprogressbar('Creating trial matrix: ');
    for b = 1:nBlocks
        
        % Trial ID
        TrialMat(1,:,b) = [1:nTrials];
        
        % Emotion and Person 
        TrialMat(2:3,:,b) = makeSequence(nTrials, nEmotions, nPeople, 0);

        % Sound
        soundsVector = zeros(1,nTrials); % preallocate soundsVector
        for i = 0:nSound-1
            soundsVector(nSoundGroups*i+1 : nSoundGroups*i+nSoundGroups) = [(i+2) * ones(1,round(nTrials/nSound))];
        end
        TrialMat(4,:,b) = soundsVector(randperm(nTrials));
        
        textprogressbar(b * 100/nBlocks);
    end
    textprogressbar('done');
return