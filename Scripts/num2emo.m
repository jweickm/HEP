% Written by Jakob Weickmann
function [emotion_string] = num2emo(input)
    compareList = {'Happy','Neutral','Angry'};
    emotion_string = strings(1,length(input));
    for i = 1:length(input)
       emotion_string(i) = compareList{input(i)}; 
    end
return