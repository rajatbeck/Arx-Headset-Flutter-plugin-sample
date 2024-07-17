# Flutter ARX Headset Integration Example

## Description

This project is a Flutter application demonstrating the integration of the ARX Headset Plugin. The application connects to the ARX Headset, displays real-time image data, IMU data, and handles various connection states including permission handling and device disconnection.

## Installation

Follow these steps to install and run the project locally:

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/flutter-arx-headset-example.git
   cd flutter-arx-headset-example 
   ```
2. **Install dependencies**
   ```flutter pub get```
3. **Run the application**
   ```flutter run```

## Usage

Upon launching the application, it will attempt to connect to the ARX Headset and display the connection status. The UI will update based on the state of the device connection, permission status, and any errors that occur. The main functionalities include:

- Connecting to the ARX Headset
- Displaying real-time image and IMU data from the headset
- Handling permission requests and device errors

## Features

- **Real-time Image Data**: Displays live image data from the ARX Headset.
- **IMU Data Display**: Shows real-time IMU data from the headset.
- **Connection Management**: Handles various connection states, including disconnected, permission not granted, and device errors.
- **User Notifications**: Uses Flutter Toast to display user notifications.

## Code Overview

### Main Components

- **UiState**: Enum to manage various UI states.
- **MyApp**: Main application widget.
- **_MyAppState**: State management for the application, including initialization and event listeners.
- **_buildBody**: Renders the UI based on the current state.
- **_buildConnectedView**: UI for when the device is connected.
- **_buildDisconnectedView**: UI for when the device is disconnected or permission is not given.

### Event Listeners

- **getPermissionDeniedEvent**: Listens for permission denial events.
- **getUpdateViaMessage**: Listens for update messages from the headset.
- **getListOfResolutions**: Listens for available resolutions from the headset.
- **getBitmapStream**: Listens for image data streams.
- **getImuDataStream**: Listens for IMU data streams.
- **disconnectedStream**: Listens for device disconnection events.

## Contributing

If you would like to contribute to this project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes.
4. Commit and push your changes to your branch.
5. Open a pull request.

## Demo Video

[Attach your demo video here]
