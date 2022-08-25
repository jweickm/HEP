% Written by Moritz Wunderwald and Jakob Weickmann (04242020)

function [trialMatrix, valid, finished] = makeSequence_(numTrials, numEmotions, numPeople, currentMatrix, DEBUG)

    % test current matrix
    matrixSize = size(currentMatrix);
    matrixLength = matrixSize(2);
    valid = checkSequence(currentMatrix, numTrials, numEmotions, numPeople, DEBUG);

    if DEBUG
        disp("### Valid: " + valid);
        disp(currentMatrix);
    end
    
    % is length reached? (aka recursion finished?)
    % return matrix if length is reached
    if matrixLength >= numTrials
        finished = true;
        trialMatrix = currentMatrix;
        return;
    else
        finished = false;
    end
    
    % at this point, we know wether the currentMatrix is valid and
    % finished.
    % if it is valid but not finished, further elements are added
    
    if ~valid
        trialMatrix = currentMatrix;
    else
        if matrixLength <= 0
            emotionPermutation = randperm(numEmotions);
        else
            emotionPermutation = makeEmotionPermutation(numEmotions, numTrials, currentMatrix(1, :));
        end
        peoplePermutation = randperm(numPeople);
        for nextEmotion = emotionPermutation
            for nextPerson = peoplePermutation
                % add elemts to current matrix
                nextMatrix = [currentMatrix [nextEmotion; nextPerson]];
                [trialMatrix, valid, finished] = makeSequence_(numTrials, numEmotions, numPeople, nextMatrix, DEBUG);
                if valid && finished
                    return;
                end
            end
        end 
    end
end

