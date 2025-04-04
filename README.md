## Overview
This BrightScript script is designed for standalone media playback on BrightSign players. It supports both single and multi-head playback configurations for Series 4 and Series 5 players. The script automatically detects the player model, configures video modes, and plays media files from the `Media` folder located in the storage device.

## Features
- Automatic detection of Series 4 and Series 5 players.
- Configurable video modes and orientations for different player series.
- Playback of video (`.MP4`, `.MOV`) and image (`.JPG`, `.JPEG`, `.PNG`) files.
- Multi-head playback support for Series 5 players.
- Automatic sorting of media files alphabetically.


## Prerequisites
1. A BrightSign player (Series 4 or Series 5).
2. A storage device (USB, SD card, or SSD) with a `Media` folder containing the media files to be played.
3. Ensure the storage device has an `autorun.brs` file for automatic execution.

## Setup
1. Copy the script file `autorun.brs` to the root of your storage device.
2. Ensure the `Media` folder exists in the root of the storage device and contains the media files you want to play.
3. Insert the storage device into the BrightSign player.

## Usage
1. Power on the BrightSign player with the storage device inserted.
2. The script will automatically execute and:
   - Detect the player model.
   - Configure the appropriate video mode and orientation.
   - Scan the `Media` folder for playable files.
   - Begin playback of the media files in alphabetical order.

## Customization
### Video Modes and Orientation
- Modify the `series4_and_older_videomode` and `series5_videomode` variables to set custom video modes.
- Adjust `m.series4_and_older_orientation` and `series5_orientation` for different screen orientations.

### Image Transition Timeout
- Update `m.ImageTransitionTimeoutVal` to change the duration for displaying images.

## Troubleshooting
1. **No Media Found**: Ensure the `Media` folder exists and contains supported media files.
2. **Playback Issues**: Verify the media files are in supported formats (`.MP4`, `.MOV`, `.JPG`, `.JPEG`, `.PNG`).
3. **Script Not Running**: Ensure the `autorun.brs` file is present on the storage device.

## Notes
- For Series 5 players (XT2145, XC2055, XC4055), the script handles multi-head playback by configuring multiple HDMI outputs.
