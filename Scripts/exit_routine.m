% Written by Jakob Weickmann
function[] = exit_routine(subjectCode, origin_folder, outlet, TrialMat, invalidTrials, stimulusSounds, uniqueSourceID, timings)
    outlet.push_sample({"end of session"});
    ListenChar();
    Screen('CloseAll')
    
   % Save Data
    disp('Saving output data to ./Output/...');
    
    TrialMatConcat = [TrialMat(:,:,1), TrialMat(:,:,2)];
    TrialMatConcat(5,1:length(TrialMat)) = 1; % Block 1
    TrialMatConcat(5,length(TrialMat)+1:end) = 2; % Block 2
    TrialMatConcat([1 2 3 4 5],:) = TrialMatConcat([5 1 2 3 4],:);
    U = table(TrialMatConcat(1,:)', TrialMatConcat(2,:)', num2emo(TrialMatConcat(3,:))', TrialMatConcat(4,:)', TrialMatConcat(5,:)',...
        'VariableNames',{'Block', 'Trial', 'Emotion', 'Person', 'Sound'});
    U.Properties.Description = strcat('Output Data for Subject', sprintf(' %02s', num2str(subjectCode)));
    U = addvars(U, subjectCode*ones(length(TrialMatConcat),1), 'Before', 'Block');
    U.Properties.VariableNames{1} = 'Subject';    
    U = addvars(U, [invalidTrials(:,1);invalidTrials(:,2)], 'After', 'Trial');
    U.Properties.VariableNames{4} = 'Attention_Getter';  
    
    U = addvars(U, stimulusSounds*ones(length(TrialMatConcat),1));
    U.Properties.VariableNames{end} = 'stimSoundsOn';
    U = addvars(U, strings(length(TrialMatConcat),1));
    U.Properties.VariableNames{end} = 'uniqueSourceID';
    U.uniqueSourceID(1:end) = uniqueSourceID;
    
    timeStamps = {'fixOn', 'fixOff', 'stimOn', 'stimOff'};
    for i = 1:length(timeStamps)
        currentTimeStamps = timings(:,i,:);
        U = addvars(U, currentTimeStamps(:));
        U.Properties.VariableNames{end} = timeStamps{i};
    end
    
    % deactivate this line if no stacking of rows is preferred
    U = stack(U, {'fixOn', 'fixOff', 'stimOn', 'stimOff'}, 'NewDataVariableName', 'timestamp', 'IndexVariableName', 'event');
    
    disp('Please wait...');
    subjectString = strcat('Subject_', sprintf('%02s', num2str(subjectCode))); % to pad the subjectCode with zeroes if necessary 
    save(strcat('./Output/', subjectString, '.mat'),  'TrialMat', 'invalidTrials', 'stimulusSounds', 'uniqueSourceID', 'timings'); 
    % this saves all the above variables to a file called Subject_.mat
    % and to a CSV file
    if exist(strcat('./Output/', subjectString, '.csv'), 'file')
        delete(strcat('./Output/', subjectString, '.csv'));
    end
    writetable(U, strcat('./Output/', subjectString, '.csv'));
    disp('Saved successfully.');
    
   % Close up shop
    sca;
    clear Screen;
    ShowCursor();
    RestrictKeysForKbCheck([]);
    disp('End of Experiment. Please stop recording.')
    cd(origin_folder);
return