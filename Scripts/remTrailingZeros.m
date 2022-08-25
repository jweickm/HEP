% Written by Jakob Weickmann
% removes trailing zeros from sound file

function[wavedataOUT] = remTrailingZeros(wavedataIN)
    [~, cols] = size(wavedataIN);
    firstIndices = zeros(1, cols);
    lastIndices  = zeros(1, cols);
    
    for c = 1:cols
        firstIndices(c) = find(wavedataIN(:,c),1,'first');
        lastIndices(c)  = find(wavedataIN(:,c),1,'last');
    end
    
    wavedataOUT = wavedataIN(min(firstIndices):max(lastIndices),:);
return
    