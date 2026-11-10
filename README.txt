AlarmApp — a simple iPhone alarm

Requires iOS 26+ and Xcode 26+ on a Mac to build and install.

OPEN AND RUN
1. Open AlarmApp.xcodeproj in Xcode on a Mac.
2. Select the AlarmApp target > Signing & Capabilities and choose your team.
   Change the bundle identifier if Xcode asks for a unique one.
3. Connect your iPhone, select it as the run destination, and press Run.
4. Choose a time and Sound 1 or Sound 2. Tap Set alarm and allow alarm access.

YOUR TWO SOUND FILES
Replace these sample tones with your own recordings, keeping the names:
  AlarmApp/Sounds/alarm1.wav
  AlarmApp/Sounds/alarm2.wav

Export as WAV, signed 16-bit linear PCM, 44.1 kHz, mono or stereo.
Keep each file shorter than 30 seconds (this app enforces that limit).
Convert the audio; renaming an MP3 extension to WAV does not convert it.
Rebuild/install after replacing the files. No code changes are needed.
The included WAVs are generated sample tones, not your custom recordings.

BEHAVIOR
One one-time alarm at a time. A time already passed means the next occurrence.
Cancel the active alarm before changing its time or sound.
AlarmKit owns scheduling, playback, and the system Stop button, including on
the locked phone. The app reads current alarms from the system on launch and
foreground entry. No background audio loop or competing app timer is used.
Scheduling and cancellation are serialized on the main actor; repeat taps
cannot create concurrent scheduling requests.

CHECK ON YOUR IPHONE
Set an alarm one minute ahead, lock the phone, and verify Sound 1 plays.
Stop it using the system control; repeat with Sound 2.
Set another alarm, close/reopen the app, and verify it still shows as set.
Cancel it and verify it does not ring. Also try denying alarm permission.
Confirm your replacement files work on the actual phone before relying on them.

VALIDATION
Created on Windows, where the iOS SDK and Xcode are unavailable. Swift syntax
and project/resource structure can be checked here; iOS compilation, signing,
and real-device alarm playback must be verified in Xcode/on your iPhone.

Apple documentation:
https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit
https://developer.apple.com/documentation/activitykit/alertconfiguration/alertsound/named(_:)
