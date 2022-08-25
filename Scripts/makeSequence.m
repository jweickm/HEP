% Written by Moritz Wunderwald (04242020)

function trialMatrix = makeSequence(numTrials, numEmotions, numPeople, DEBUG)
    [trialMatrix, valid, ~] = makeSequence_(numTrials, numEmotions, numPeople, [], DEBUG);
    if ~valid
        error("No valid sequence could be found");
    end
end

