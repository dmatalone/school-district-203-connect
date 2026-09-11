# Native iPhone Screen Broadcast

This folder is the native version needed for iPhone. Safari cannot broadcast the whole iPhone screen after you leave Safari, so this uses Apple's ReplayKit Broadcast Upload Extension.

## How this version works

1. Run the relay on the Windows computer (`relay/server.js`).
2. Put the computer's local IP into the iPhone app, for example `ws://192.168.1.25:8080`.
3. The iPhone app generates one 6-digit pairing code.
4. Tap **Start Broadcast** on iPhone and choose the School District 203 broadcast extension.
5. On Windows open `http://localhost:8080`, enter the iPhone code, and click **Connect**.
6. The iPhone screen appears in the browser. Click **Full Screen** to fill the monitor.

The iPhone and Windows computer must be on the same Wi-Fi network for the local relay version.

## Xcode setup

Create an iOS app target named `District203Connect` and a **Broadcast Upload Extension** target named `District203Broadcast`.

Add these source files:
- `ios/ContentView.swift` to the app target
- `ios/SharedConfig.swift` to BOTH targets
- `ios/BroadcastUpload/SampleHandler.swift` to the Broadcast Upload Extension target

Enable the App Group capability on both targets using:

`group.schooldistrict203.connect`

The Broadcast Upload Extension's bundle identifier can be something like:

`org.schooldistrict203.connect.broadcast`

The app uses `RPSystemBroadcastPickerView`, so the user explicitly starts the broadcast from iOS as required by Apple.

## Important

This is source code; GitHub Pages cannot compile or install an iPhone app. You need a Mac with Xcode and an Apple ID/development signing profile to install it on an iPhone.