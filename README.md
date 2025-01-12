**TLDR**: Make calls via your Garmin device without taking your phone out of the pocket.

###### **Beta-testers wanted!**

**If you're interested in joining the beta, please reach to me or send a request to join the [dedicated Google group](https://groups.google.com/g/handsfree-beta) - I'd really appreciate that.**

### Features

-   Outgoing calls to starred contacts
-   Incoming calls [beta]
-   Custom *continuous* vibration pattern (on Fenix 7)
-   Recent contacts [beta]
-   Missed calls [beta]
-   In-call audio *volume* control [beta]
-   Phone speaker enabled on *outgoing* calls without headset [beta]
-   Headset connection status
-   Glance view/making calls during an activity (on supported devices)

# Why

For one reason or another, most of the times I find myself wearing Bluetooth headset connected to my Android phone (to be specific, it's hearing aids in my case). The same phone is connected to my Garmin watch.

The watch (one of the best watches in the world, if you ask me), allows me to control Music, Podcasts and, among other things, to *answer and control the incoming calls* on the phone. What it does not allow me, yet, is to *initiate and control the outgoing calls*. Handsfree fills that gap.

# How

There're two components of the solution: the app running on the watch and the companion app running on an Android phone.

## Companion (Android) app

-   Serves the your requests from the watch, e.g. directing the phone to initiate or to hangup a call.
-   Sends the updates to the watch, so that you see the call in progress, if any
-   Sends the data/phones from the preselected contact group (currently, starred contacts), to the watch, so that you can select a phone to dial.

## Garmin watch app

-   Shows you the list of the starred contacts provided by companion app
-   Lets you start and control the outgoing call for a selected contact phone
-   Lets you control the calls in progress, even when they're *not* initiated from the watch
-   Shows status of Bluetooth headset connection in the app/glance (# in the title means no headset is connected to the phone), so you can be sure that  the headset will be used for the call.

# Demo

Following is the demo of the app running in Simulators. Beware that Simulator does not show the glance/terminates the app on navigation from the app - that's not a bug, rather a limitation of Simulator/on real device you would see the glance again: during the demo I had to restart the app, so that the glance would reappear.

https://s3.amazonaws.com/gentin.connectiq.handsfree/Handsfree-Demo.mp4

# Getting started

## Requirements

-   Garmin watch or bike computer (see [Garmin IQ app page](https://apps.garmin.com/apps/73107243-f322-4cf2-bb3d-78f2a4ee8920?tid=1) for the list of supported models)
-   Android phone (currently limited to Android 10 or later), with Garmin Connect app installed and connected to the watch
-   iPhones are not supported (I could not find a way to drive calls there without explicit user confirmation for each call).

## Installation

##### [Handsfree app](https://apps.garmin.com/en-US/apps/73107243-f322-4cf2-bb3d-78f2a4ee8920) for Garmin watch

[<img src="./badges/Connect-IQ/Connect-IQ-Badge_White.svg" alt="available-connect-iq-badge" height="88"/>](https://apps.garmin.com/en-US/apps/73107243-f322-4cf2-bb3d-78f2a4ee8920)

##### [Handsfree companion app](https://grigorye.github.io/handsfree/Installation) for Android phone

There're currently a couple ways to obtain the Android app.

1.   **If you joined the [beta program](https://groups.google.com/g/handsfree-beta)**, you can already benefit from installing the Android app from Google Play:

[<img src="./badges/Google-Play/Get-It-On-Google-Play-Badge_en.svg" height="80" />](https://play.google.com/store/apps/details?id=com.gentin.connectiq.handsfree) 

2.   If you are not a beta tester (or prefer to not depend on Google Play), you can install the latest version of the app from the page below:

https://grigorye.github.io/handsfree/Installation

## Setup

-   Install the Android app, open it, and toggle all the features on (preferably) - you'll get prompts for the necessary permissions.
-   Check/adjust the list of favorites on your phone.
-   Check https://dontkillmyapp.com for your phone model (the link that should automatically show hints for your phone model is available in About > Troubleshooting > Hints for running apps in background on your phone in Android app).
-   Install the watch app, launch it. It should get the list of the contacts from the phone and you should be ready to go.

## Making calls

Open the app on the watch.

Select a contact phone to start the call.

If the phone is not connected to a headset, Handsfree will automatically activate the phone speaker. (Beware that this function is not available on accepting the calls.)

The "Call in progress" screen will be shown with the following options:

-   Hang Up - lets you hangup the call
-   Volume: XXX% - lets you change audio volume (the audio volume screen will show SPKR or HSET to indicate either speaker or headset currently active)
-   Mute/Unmute - lets you temporarily mute *your microphone*, so that the other party would not hear you.

To go back to the watch without hanging up the call, just select Back.

To return to the call in progress after going back to watch, just launch the app again.

## Accepting calls

Select "Incoming Calls" in Settings of Handsfree on your watch.

(Optionally) disable Garmin's own support for accepting the calls on the watch.

Depending on your watch model, on incoming call:

-   (Most of the watch models) You'll get a notification about a call, that prompts into launching Handsfree app. If you accept the prompt, Handsfree will be launched and you'll get the prompt to Accept/Decline the call.
-   (Fenix 7 family of the watches) After some delay, you'll get the prompt to Accept/Decline call, with the watch vibrating until you make your choice.

## Accessing recent calls

Navigate Recents in Handsfree on you watch, and you should see the recent contacts (max 5) involved in the calls, as long as the date/time of the last call associated with the given contact and indicator of the type of the call:

-   ">" - incoming call
-   "<" - outgoing call
-   "-" - declined call
-   "!" - (new) missed call
-   "?" - (old) missed call
-   "r" - call routed to voicemail
-   "b" - blocked call
-   "a" - answered externally

Selecting an entry in the recent calls, will trigger a call to the contact selected.

## Watch app optimizations

There're a couple settings (enabled by default) that speed up the operation/responsiveness of the watch app. If you encounter some problems with the operation, it may be worth checking if turning a setting off could work as a workaround.

-   **Faster Calls** - the watch app assumes that requests that it sends to the phone succeed, even before it gets a confirmation from the phone. The app indicates such a case by placing "|" around the texts shown. For example, right after selecting a contact to initiate a call, Handsfree will show you "Call in progress" screen, with a contact name, options to Hang Up/Control the sound volume and etc. - those can actually be used right away. For a few seconds, it will show the contact name (e.g. John Doe) like "|John Doe|", then the contact name will be shown as "John Doe".

    With this setting *disabled* you will not get to the "Call in Progress" screen until the moment when the watch actually receives the confirmation from the phone - that takes a few seconds and may be confusing, because you the call in fact may be already in progress.

-   **Background Sync** - all the changes in recents/favorites that happen on the phone are automatically pushed to the watch, even if you don't open the watch app. This results in no need to sync anything when you open the watch app - all the information is instantly available on the watch. Enabling this setting may potentially decrease the battery life of your watch, however, the negative effect (compared to manual sync) should be minimal, as the the data is pushed during the calls *anyway* and with background sync only slightly more data is pushed to the watch (particularly, changes in recents).

# Troubleshooting

It's critical for the companion app to be able to run in background and to be able to receive the requests from the watch. To avoid troubles, I really recommend to take a look at https://dontkillmyapp.com and follow instructions for your specific phone model, to let Handsfree *and* Garmin Connect app run in the background.

# Overview of Garmin watch app screens

<img src="WatchApp-Flow.svg" alt="WatchApp-Flow" width="60%" />



# Disclaimer

I'm neither Garmin nor Android software developer (I'm iOS/ex. macOS developer in my day life though). This is my first and the only pet project that utilizes either of the platforms.
