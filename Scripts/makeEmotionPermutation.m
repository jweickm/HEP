function [seq] = makeEmotionPermutation(numEmotions, numTrials, emotionSequence)
    maxCountEmotions = numTrials/numEmotions;
    lastEmotion = emotionSequence(length(emotionSequence));
    candidates = setdiff([1:numEmotions], lastEmotion);
    
    countRemainingEmotions = maxCountEmotions * ones(1, numEmotions);
    for e = emotionSequence       
        countRemainingEmotions(e) = countRemainingEmotions(e) - 1;
    end
    
    seq = candidates(randperm(length(candidates)));
    for emotionIndex = candidates
        if countRemainingEmotions(emotionIndex) > sum(countRemainingEmotions) - countRemainingEmotions(emotionIndex);
        	seq = [emotionIndex];
        end 
    end
end

