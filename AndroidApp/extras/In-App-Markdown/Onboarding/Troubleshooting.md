# Troubleshooting

There are several components that should work together for normal operation of Handsfree. If it does not work as expected, especially when your setup changes (e.g. you added or removed Garmin device, got new phone or OS update), try the hints below. They cover all the known problems so far.

### In general/beforehand

**Make sure that the watch app is _not_ installed and running on multiple Garmin devices, simultaneously**: that's known to cause all kinds of troubles. Either install it on a single Garmin device or try to keep only one device running Handsfree, connected to your phone.

**[Follow hints for running apps in background on your phone](do://doki)** - this is crucial to do after you first install the app.

**[Check Handsfree app settings](do://settings)** to make sure the necessary permissions are given, it's not blocked from running in the background by something extra and etc.

### If things go wrong out of sudden

**[Force stop Garmin Connect](do://garmin-connect-settings)** - this may be the dealbreaker when Handsfree does not respond to watch app (things happen) - just tap "Force stop" to kill the app (there's no need to restart it - that will be done automatically). Sometimes it needs to be followed by resetting the connection to the phone, see below.

**Toggle the connection to your phone off and then back on from the settings on your Garmin device** - this is known to help when the phone does not respond to your commands from the watch app.

**[Reconnect with the watch](do://reconnect-connectiq)** (you can tap the devices list on the Control screen to reconnect as well) - this may be worth trying, especially if you don't want to kill Garmin Connect (see above).

**Reboot your phone** - yes, that may mean a lot, but it's for sure probably the simplest thing to do once in a while.

### May be helpful in certain situations

**[Toggle debug mode](do://toggle-debug-mode)** - only if asked, or you want to see the internal stats instead of the usual notification content.

**[Save Log](do://share-log)** - only if asked, to debug the app.

**[Restart the service](do://restart-service)** - as an alternative to force stopping the app.

**[Open app on the watch](do://open-watch-app)** - just to check that it's there.

**[Open app in Connect IQ](do://open-app-in-store)** - e.g. to check the latest version (it does not work reliably, though).

**[Ping app on the watch](do://ping)** - to verify the connection.

**[Toggle watch simulator](do://toggle-emulator-mode)** - should be used for development only.
