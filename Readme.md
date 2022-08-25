# Stimulus Presentation for Heartbeat Evoked Potentials (HEP)

Updated on Jun 9th 2020. 

This script was written in Matlab and uses the Pyschophysics Toolbox for stimulus presentation. It presents a variety of facial stimuli with different emotional valence to be used in an ECG/EEG paradigm that measures heartbeat-evoked potentials (HEP). 

## Design
![Design](https://github.com/wunderwald/MindTheBody/blob/Jakob/HEP/readme/design.png) ![Attention Grabber](https://github.com/wunderwald/MindTheBody/blob/Jakob/HEP/readme/attentionGrabber.png) 

- Neutral gray screen with some jitter  
	- 1500 to 2500 ms for the first [with baby] block  
	- 500 to 1500 ms for the second [parent only] block  
- Fixation cross is presented for 1000 ms together with a sound
- Gray screen mask for 400 ms
- Facial stimulus presentation for 3000 ms 

An attention grabber animation with sound can be activated at any time during the script by pressing the 'G' key. Pressing the 'H' key returns to the script. If the attention grabber is activated during stimulus presentation, the current trial will be marked as invalid, otherwise it is simply repeated. 

Different numbers of emotions as well as a different number of facial stimuli can be used. The current iteration of the script presents three types of emotional faces (happy, neutral, angry) of 16 actors, resulting in 48 stimuli overall. These are presented in a pseudo-randomized order over 48 trials and two blocks. 

## Ordering Algorithm
The ordering algorithm fits the 48 visual stimuli to the 48 trials while making sure that two emotions of the same type are not displayed consecutively. Additionally, the same actor is also not shown twice in a row. It is a trial and error algorithm that is optimized towards quick runtimes by excluding already at an early stage those branches that are sure to contradict with the abovementioned conditions. For more details on this algorithm take a look at [`makeSequence_.m`](./Scripts/makeSequence_.m) and [`checkSequence.m`](./Scripts/checkSequence.m); as well as [`makeEmotionPermutation.m`](./Scripts/makeEmotionPermutation.m) for the exclusion of 'dead' branches by using a remaining sum method. 

## Running the Script
```
HEP_Experiment(screenNumber,SkipTests,uniqueSourceID,Fullscreen,stimulusSounds)
```
Run the script in its default configuration from the terminal by typing `HEP_Experiment`. Using the parameters below the execution of the script can be adjusted to your needs. 

Parameter        | Usage
-----------------| -----------------------------------
`screenNumber`   | set the screen that will be used for stimulus presentation (highest screen number by default)
`SkipTests`      | set to `1` to skip initial Psychtoolbox tests (`0` by default)
`uniqueSourceID` | set the name of the streaming device for use with LabRecorder (`'Mangold PC'` by default)
`Fullscreen`     | set to `0` to run script in a small on-screen window (`1` by default)
`stimulusSounds` | set to `1` to enable pseudo-randomly distributed sounds to play at stimulus presentation in addition to the fixation cross sound (`0` by default)

**Example:**  
`HEP_Experiment(2, 1,'labComputer1', 1, 0)` will display the script on the screen #2, skip the tests, send the stream with the source ID `'labComputer1'`, run the script in full-screen mode and not play any additional stimulus sounds. 

## Keyboard Functions
Key                       | Function
--------------------------|-----------------------------
ENTER [ ↵ ] or SPACE [ ␣ ] | advance the script 
ESCAPE [ Esc ]              | abort the script and save to output
[ X ]                       | abort the current block
[ G ]                       | display an attention grabber (script will pause)
[ H ]						| return to script from attention grabber display
[ P ]						| pause the script (off the record)

## Prerequisites
- [Mathworks Matlab](https://www.mathworks.com/)
- [Psychtoolbox](http://psychtoolbox.org/)
- [GStreamer](https://gstreamer.freedesktop.org/) 
- [LSL LabRecorder](https://github.com/labstreaminglayer/App-LabRecorder) 

## Getting Started

### File Import
#### Images 
Make sure that the visual stimuli are located in their corresponding folders, i.e. 'happy' stimuli belong into the `Happy` folder and so on. The script will scan the folders for image import and identify whether an image shows a female or a male. The images should be named something like `*_female_angry*.jpg`. `*` represents a wild card character. 

#### Sounds
Additionally, sounds should be in WAV format and placed into the `Sound_files` folder. The first file (alphabetically) in that folder will be used for the fixation cross, so it should be named accordingly. 

#### 'Stimuli' folder
After running the script for the first time, the images and sounds are saved as MAT files in the `Stimuli` folder. The script will scan every time if these files already exist and skip import in that case. Therefore, the original image and sound files can then be deleted to save disk space. If changes are made to images or sounds, deleting the corresponding MAT file in the `Stimuli` folder causes the script to import again. 

### Scripts
The `Scripts` folder contains all the necessary scripts that are called during the execution of the main script. 

### Stimulus Presentation
Only a part of the images will be shown and scaled to fit the screen vertically (minus ten percent). To change this part, modify the line `sourceRect = [***]` in the script under the section `EXPERIMENT PARAMETERS: TEXT, STIMULI, DURATIONS`. 

### Export
After successfully running the script or by aborting it via `[Escape]` or `[X]` the precise timings of each trial as well as a cleaned-up trial matrix are exported to the `Output` folder. Both a MAT file and a CSV file with the subject ID in the filename are created. 

## Authors
- **Jakob Weickmann** (main code)
- **Moritz Wunderwald** (ordering algorithm and general support)

## License
This project is licensed under the MIT License - see the [`License.md`](License.md) for details.

## Acknowledgements
- This script was written in Matlab, using the Psychophysics Toolbox extensions (Brainard, 1997; Pelli, 1997; Kleiner et al, 2007).
- The facial stimuli are provided by the [Radboud Faces Database](http://www.socsci.ru.nl:8180/RaFD2/RaFD?p=main).
- Thanks to the [Uppsala Child and Baby Lab](https://psyk.uu.se/uppsala-child-and-baby-lab/research/) for letting us use their attention grabbers.

## References
- Brainard, D. H. (1997) The Psychophysics Toolbox, Spatial Vision 10:433-436.
- Kleiner M, Brainard D, Pelli D, 2007, “What’s new in Psychtoolbox-3?” Perception 36 ECVP Abstract Supplement. 
- Langner, O., Dotsch, R., Bijlstra, G., Wigboldus, D.H.J., Hawk, S.T., & van Knippenberg, A. (2010). Presentation and validation of the Radboud Faces Database. Cognition & Emotion, 24(8), 1377—1388. DOI: 10.1080/02699930903485076
- Pelli, D. G. (1997) The VideoToolbox software for visual psychophysics: Transforming numbers into movies, Spatial Vision 10:437-442.