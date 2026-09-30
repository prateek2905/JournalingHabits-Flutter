# iOS home-screen widgets (WidgetKit)

The SwiftUI sources here are ready; the Xcode *target* has to be created once on a Mac
(a widget extension can't be added from the command line without hand-editing the .pbxproj).

1. Open `ios/Runner.xcworkspace` in Xcode.
2. File > New > Target > **Widget Extension**. Name it `HabitsWidgets`, uncheck
   "Include Live Activity" / "Include Configuration App Intent". Set the deployment target to iOS 16+.
3. Delete the files Xcode generates for the target, then add the files in this folder
   (`Shared.swift`, `HabitsWidget.swift`, `JournalWidget.swift`, `SleepWidget.swift`,
   `Info.plist`, `HabitsWidgets.entitlements`) to the `HabitsWidgets` target.
4. Signing & Capabilities: add **App Groups** with `group.com.prateekmishra.journalingHabits`
   to BOTH the `Runner` target (use `Runner/Runner.entitlements`) and the `HabitsWidgets` target
   (use `HabitsWidgets/HabitsWidgets.entitlements`).
5. Build & run, then long-press the home screen > + > "Journaling Habits".

The app pushes data with `lib/services/widget_sync.dart`; taps deep-link to
`journalinghabits://journal|habits|sleep` (URL scheme already registered in `Runner/Info.plist`).
