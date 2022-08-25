% Written by Jakob Weickmann

function [facialStimuli] = imageImport(separate_Folders)

nFaces = zeros(3,2); % preallocate
if separate_Folders
    % import faces
    images = ["./Happy/*_female_*.jpg", "./Happy/*_male_*.jpg"; ...
        "./Neutral/*_female_*.jpg", "./Neutral/*_male_*.jpg"; ...
        "./Angry/*_female_*.jpg", "./Angry/*_male_*.jpg"];
    directory = ["./Happy/", "./Neutral/", "./Angry/"];
    [emotions, sex] = size(images);

    facialStimuli = cell(length(dir(images(1))), 2, 3); % preallocate location for images
    % rows are images, columns are sex and 3rd dimension is emotion

    textprogressbar('Importing images:      '); % initialize textprogressbar    
    for e = 1:emotions % loop over emotion
        for s = 1:sex % loop over sex
            facialStimuli_dir = dir(images(e, s)); % set the current selection of images
            nFaces(e, s) = length(facialStimuli_dir); % record the number of images in that category to nFaces
            for i = 1:length(facialStimuli_dir) % loop over images in that category
                facialStimuli{i, s, e} = imread(strcat(directory{e}, facialStimuli_dir(i).name)); % save in facialStimuli
            end
        end
        textprogressbar(e * 100/emotions);
    end
    textprogressbar('done');
else
    % import faces
    images = ["./Images/*_female_happy*.jpg", "./Images/*_male_happy*.jpg"; ...
        "./Images/*_female_neutral*.jpg", "./Images/*_male_neutral*.jpg"; ...
        "./Images/*_female_angry*.jpg", "./Images/*_male_angry*.jpg"];
    [emotions, sex] = size(images);
    facialStimuli = cell(length(dir('./Images/*.jpg'))/(sex * emotions), sex, emotions); % preallocate

    textprogressbar('Importing images:      '); % initialize textprogressbar    
    for e = 1:emotions % loop over emotion
        for s = 1:sex % loop over sex
            facialStimuli_dir = dir(images(e, s)); % set the current selection of images
            nFaces(e, s) = length(facialStimuli_dir); % record the number of images in that category to nFaces
            for i = 1:length(facialStimuli_dir) % loop over images in that category
                facialStimuli{i, s, e} = imread(strcat('./Images/', facialStimuli_dir(i).name)); % save in facialStimuli
            end
        end
        textprogressbar(e * 100/emotions);
    end
    textprogressbar('done');
end

% Save stimuli in mat file
textprogressbar('Saving images to .mat: ');
save('./Stimuli/images.mat', 'facialStimuli', 'nFaces');
textprogressbar(100);
textprogressbar('done');

return