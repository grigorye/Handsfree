**TLDR**: If you wear a Garmin watch and prefer to keep your Android phone in your pocket while making calls (meaning, you're wearing some kind of earphones), you can find Handsfree useful.

# Why

For one reason or another, most of the times I find myself wearing Bluetooth headset connected to my Android phone (to be specific, it's hearing aids in my case). The same phone is connected to my Garmin watch.

The watch (one of the best watches in the world, if you ask me), allows me to control Music, Podcasts and, among other things, to *answer and control the incoming calls* on the phone. What it does not allow me, yet, is to *initiate and control the outgoing calls*. Handsfree fills that gap.

# How

There're two components of the solution:

-   Handsfree app for Garmin watch
-   Handsfree companion app for Android phone

## Companion (Android) app

-   Serves the your requests from the watch, e.g. directing the phone to initiate or to hangup a call.
-   Sends the updates to the watch, so that you see the call in progress, if any
-   Sends the data/phones from the preselected contact group (currently, starred contacts), to the watch, so that you can select a phone to dial.

## Garmin watch app

-   Shows you the list of the starred contacts provided by companion app
-   Lets you start and control the outgoing call for a selected contact phone
-   (As a bonus) lets you control *any* call in progress on your Android phone, even if it's not initiated from the watch.

# Demo

Following is the demo of the app running in Simulators. Beware that Simulator does not show the glance/terminates the app on navigation from the app - that's not a bug, rather a limitation of Simulator/on real device you would see the glance again: during the demo I had to restart the app, so that the glance would reappear.

https://s3.amazonaws.com/gentin.connectiq.handsfree/demo-67cb5b1.mp4

# Getting started

## Requirements

-   Garmin watch
-   Android phone (currently limited to Android 10 or later), with Garmin Connect app installed and connected to the watch

## Setup

-   Install the Android app, open it, and give it permissions to run in background, access your contacts and control your calls. (You should see "GRANT PERMISSIONS" if any permissions are missing, otherwise you should see "MANAGE PERMISSIONS" button)
-   Put contacts you want to dial from the watch, into the starred contacts (tap "SELECT CONTACTS" if you want to modify those).
-   Install the watch app, launch it. It should get the list of the contacts from the phone and you should be ready to go.

### Making calls

-   Open the app on the watch.
-   Select a contact phone to start the call.
-   To hangup the call, select "Yes" in the "Hang up?" prompt
-   To close the prompt/return back to the watch without hanging up the call, just press Back (or select "No").
-   To return to the call in progress after going back to watch, just launch the app again.

# Troubleshooting

It's critical for the companion app to be able to run in background and to be able to receive the requests from the watch. To avoid troubles, I really recommend to take a look at https://dontkillmyapp.com and follow instructions for your specific model of the phone (you can see those by tapping "HOW TO RUN IT IN THE BACKGROUND" button inside the app), to let Handsfree *and* Garmin Connect app run in the background.
