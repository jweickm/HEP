% Written by Jakob Weickmann

function [sounds] = convert2stereo(sounds)

% Make sure we have always 2 channels stereo output.
% Why? Because some low-end and embedded soundcards
% only support 2 channels, not 1 channel, and we want
% to be robust in our experiment.
    textprogressbar('Converting to stereo:  ');
    for i = 1:length(sounds)
        if size(sounds(i).y',1) < 2 % if it is not stereo
            sounds(i).y = [sounds(i).y, sounds(i).y]; % make it stereo
            textprogressbar(i * 100/length(sounds));
        end
    end
    textprogressbar('done');
return
    