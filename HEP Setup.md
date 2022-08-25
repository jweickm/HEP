# Structure of the HEP Script [Draft]

2020/04/01

- [x] initial setup
- [x] Display gray screen for ~ 500 ms 
- [x] fixation cross for ~ 1000 ms  
- [x] load images and make textures
- [x] display randomized image (angry, happy, neutral, 90° frontal view) with a sound (different sounds) for ~ 3000 ms
- [x] insert triggers
- [x] synchronize triggers with labstreaminglayer
- [x] around 48 trials  
- [x] a break  
- [x] another 48 trials (just the mother)
- [x] one image per trial  
- [x] 8 or 4 sounds  
- [x] do not show the same emotion twice in a row  
- [x] do not show the same actor twice in a row  
- [x] record gender  
- [x] insert sound when a face is shown  (1-8)
- [x] insert fixation cross sound (1st file)
- [x] attention grabber sound (10)
- [x] shift loops to account for .gitignore
- [x] implement attention grabber (like a rotating spiral) that can be 
triggered manually by a button press    (**when and how?**)
- [x] change to a repeating loop with the screen frequency so that button 
presses are recorded instantly  
- [x] insert break key  
- [x] restrict input keys  
- [x] insert instructions  
- [x] send meaningful triggers  
- [x] figure out how to plot trigger stream  
- [x] implement conditional loading of images and export structure

- [x] Test ping/delay with EEG 
- [x] Test triggers with LSL
- [x] communication between 2 computers (remote input into LSL) 

- [x] Inter Trial Interval 2 sec (+- 500ms) with Jitter
- [x] shorter iti for the 2nd block
- [x] adjust image size to fill almost the entire screen
- [x] cut out the images as a square (abandoned)
- [x] implement preloading of videos during playback
- [x] ListenChar
- [x] popup window to enter the ID
- [x] Export to Folder with ID (Timings, TrialMatrix, AttentionGetter)
- [x] Rename Stimuli to fit with number tag in TrialMat
- [x] mute facial stimuli sounds with a function switch 

- [x] send different keys for different emotions ('h', 'a', 'n')
- [x] export stimulus onset timings, etc. 
- [x] export everything in one table, timings. will result in several lines per trial
- [x] transponieren und ID, sounds yes no in every cell
- [x] in zeilen mit ueberschriften 
- [x] catch error with textprogressbar! and fix so that the script runs normally even with the error
- [x] map image size to y axis
- [x] improve sound timings

- [x] discuss display screens with Moritz
- [x] write Readme

- [ ] change MAIN DISPLAY from script?
- [x] change order of defaults 
- [x] also change it in readme
- [x] implement neutral pause function
- [x] remove one of the instruction windows? or at least the timers
- [x] ask if ID is correct
- [x] implement function for choosing the right display (2)
- [x] or disp 1 as the default disp
- [x] send screenshots and readme to julia
- [x] show on ptb Window: Das Experiment beginnt nun...
- [x] add function to initialize stream before opening the onscreen window
- [x] stream in matlab anpassen
