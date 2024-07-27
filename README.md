**TLDR**: If you wear a Garmin watch and prefer to keep your Android phone in your pocket while making calls (meaning, you're wearing some kind of earphones), you can find Handsfree useful.

###### **Beta-testers wanted!**

**If you're interested in joining the beta, please reach to me or send a request to join the [dedicated Google group](https://groups.google.com/g/handsfree-beta) - I'd really appreciate that.**

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

-   Open the app on the watch.
-   Select a contact phone to start the call.
-   To hangup the call, select "Yes" in the "Hang up?" prompt
-   To close the prompt/return back to the watch without hanging up the call, just press Back (or select "No").
-   To return to the call in progress after going back to watch, just launch the app again.

# Troubleshooting

It's critical for the companion app to be able to run in background and to be able to receive the requests from the watch. To avoid troubles, I really recommend to take a look at https://dontkillmyapp.com and follow instructions for your specific phone model, to let Handsfree *and* Garmin Connect app run in the background.

# Overview of Garmin watch app screens

<img src="WatchApp-Flow.svg" alt="WatchApp-Flow" width="60%" />



# Disclaimer

I'm neither Garmin nor Android software developer (I'm iOS/ex. macOS developer in my day life though). This is my first and the only pet project that utilizes either of the platforms.
