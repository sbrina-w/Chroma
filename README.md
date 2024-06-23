# Chroma: Your Personal Colour Assistant

Chroma is a mobile app designed to facilitate colour palette creation and paint mixing tasks.

## Hackathon Submission

A WaffleHacks 2024 Submission. View on devpost: https://devpost.com/software/chroma-q3wshr

## Features

- **Personal Colour Palette**: User can manually add colours to create their personal colour palette, or upload a picture of paint swatches (with a transparent background) for automatic colour extraction.
- **Reference Photo Analysis**: User can take a photo within the app or upload a photo from their device to use as a reference image, and the app will create a colour palette based on the most prominent colours in the reference image.
- **Colour Ratio Calculation**: Calculates how much of each colour (in the user's personal palette) is needed to get to a target colour (from the reference image's palette).
- **Virtual Colour Mixer**: Simulates the mixed colour and compares it with the target colour.

## Usage

1. Ensure you have Flutter SDK and Dart SDK installed
2. Clone the repository
3. Install dependencies (run "flutter pub get")
4. Run the app ("flutter run")

Note: a physical device is needed to use the app in order to use the camera or upload an image from device storage.


## How to Use:
1. Launch the app on your physical device.
2. Add your paint colours (manually or by uploading a transparent image of your paint swatches).
3. Take or upload a photo to use as a reference image. The app will extract the prominent colours from this image as a palette.
4. Customize palette by adding, editing, or deleting colours.
5. Tap on a prominent colour from the reference image and the app will display the mixing ratios and the simulated mixed colour.


## Collaboration

This project was developed collaboratively by Ruby Lu (ruby-lu-05) and Sabrina Wang (sbrina-w).
