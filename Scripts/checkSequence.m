% Written by Moritz Wunderwald and Jakob Weickmann (04242020) 

function valid = checkSequence(currentMatrix, numTrials, numEmotions, numPeople, DEBUG)
    valid = true;
    
    matrixSize = size(currentMatrix);
    length = matrixSize(2);
    
    if length <= 1
        return;
    end
    
    % check for repetitions
    if currentMatrix(1, length) == currentMatrix(1, length-1) ...
            || currentMatrix(2, length) == currentMatrix(2, length-1)
        valid = false;
        if DEBUG 
            disp("### repetitition");
        end
        return;
    end
    
    % test amount of each emotion/person index
    countEmotions = zeros(1, numEmotions);
    countPeople = zeros(1, numPeople);
    maxCountEmotion = numTrials/numEmotions;
    maxCountPeople = numTrials/numPeople;
    % ... and count emotion types per person
    emotionPerPerson = zeros(numPeople, numEmotions);
    maxEmotionCountPerPerson = numTrials/(numPeople*numEmotions);
    
    %count emotion/people types
    for i=1:length
        currentEmotion = currentMatrix(1, i);
        currentPerson = currentMatrix(2, i);
        countEmotions(currentEmotion) = countEmotions(currentEmotion) + 1;
        countPeople(currentPerson) = countPeople(currentPerson) + 1;
        emotionPerPerson(currentPerson, currentEmotion) = ...
            emotionPerPerson(currentPerson, currentEmotion) + 1;
    end
    for e = 1:numEmotions
        if countEmotions(e) > maxCountEmotion
            if DEBUG
                disp("### emotion count");
            end
            valid = false; 
            return;
        end
    end
    for p = 1:numPeople
        if countPeople(p) > maxCountPeople
            if DEBUG
                disp("### person count");
            end
            valid = false;
            return;
        end
    end
    for p = 1:numPeople
        for e=1:numEmotions
            if emotionPerPerson(p, e) > maxEmotionCountPerPerson
                if DEBUG
                    disp("### emotion per person count, p=" + p + ", e=" + e);
                end
                valid = false;
                return;
            end
        end
    end
    
    
    
end

