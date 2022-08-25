% Written by Jakob Weickmann
% Attention Getter plays until one presses a key again (NOT 'G'!)

function[droppedframes] = attentionGetterPlayback(windowPtr, windowRect, secs, origin_folder, Fullscreen)
    
    Screen('Flip', windowPtr); % initial flip
    
    if Fullscreen
        movieRect = [0, 0, windowRect(3), windowRect(4)];
    end
    
    movie_dir = dir('./Attention_getter/*.mp4');
    moviePtr = zeros(1,length(movie_dir));

    currentMovie = randi(length(moviePtr));
    absolutePathToMovie = strcat(origin_folder, '/Attention_getter/', movie_dir(currentMovie).name);

    % Load movie
    moviePtr = Screen('OpenMovie', windowPtr, absolutePathToMovie);

    [droppedframes] = Screen('PlayMovie', moviePtr, 1, 1, 1);
        while GetSecs <= (secs + 0.5) || ~KbCheck() % attention getter has to run for at least 500 ms

            % Wait for next movie frame, retrieve texture handle to it
            tex = Screen('GetMovieImage', windowPtr, moviePtr);

            % Valid texture returned? A negative value means end of movie reached:
            if tex<=0
                % We're done, break out of loop:
                break;
            end 
            
            % Draw the new texture immediately to screen:
            if Fullscreen
                Screen('DrawTexture', windowPtr, tex, [], movieRect);
            else
                Screen('DrawTexture', windowPtr, tex, []);
            end

            % Update display:
            Screen('Flip', windowPtr);

            % Release texture:
            Screen('Close', tex);
        end
        
    % Stop playback:
    Screen('PlayMovie', moviePtr, 0);
    
    % Close Movie
    Screen('CloseMovie', moviePtr);
    
    % Update display:
    Screen('Flip', windowPtr);
return