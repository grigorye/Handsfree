**TLDR**: Make calls via your Garmin device without taking your phone out of the pocket.

###### **Beta-testers wanted!**

**If you're interested in joining the beta, please reach to me or send a request to join the [dedicated Google group](https://groups.google.com/g/handsfree-beta) - I'd really appreciate that.**

# Why

For one reason or another, most of the times I find myself wearing Bluetooth headset connected to my Android phone (to be specific, it's hearing aids in my case). The same phone is connected to my Garmin watch.

The watch (one of the best watches in the world, if you ask me), allows me to control Music, Podcasts and, among other things, to *answer and control the incoming calls* on the phone. What it does not allow me, yet, is to *initiate and control the outgoing calls*. Handsfree fills that gap.

# Features

-   [Call control](./docs/Call-Control.md)
-   [Outgoing calls](./docs/Outgoing-Calls.md)
-   [Incoming calls](./docs/Incoming-Calls.md)
-   [Customizable *continuous* vibration on an incoming call](./docs/Vibration.md) (Fenix 7 only)
-   [Recent contacts](./docs/Recents.md)
-   [Missed calls](./docs/Missed-Calls.md)
-   [In-call audio *volume* control, microphone muting](./docs/In-Call-Audio.md)
-   [Headset status](./docs/Headset-Status.md)
-   [Speaker phone control](./docs/Speaker-Phone.md)
-   [Seamless syncing](./docs/Syncing.md)
-   [Glance view](./docs/Glance.md)

# How

There're two components of the solution: the app running on the watch and the companion app running on an Android phone.

## Companion (Android) app

Acts like a (dumb) relay between the watch and the rest of the phone:

-   Serves your requests from the watch, e.g. directing the phone to initiate or to hangup a call
-   Sends the updates to the watch, so that you see a call in progress, if any
-   Sends the data/phones from the preselected contact group (currently, starred contacts), to the watch, so that you can select a phone to dial
-   Sends the call history to the watch
-   Sends the state of your headset/microphone to the watch

## Garmin watch app

-   Shows you the list of the starred contacts provided by companion app
-   Lets you start and control the outgoing call for a selected contact phone
-   Lets you control the calls in progress, even when they're *not* initiated from the watch
-   Shows status of Bluetooth headset connection in the app/glance (# in the title means no headset is connected to the phone), so you can be sure that  the headset will be used for the call.

# Demo

https://youtu.be/xiZ8kEoOO0Q

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

1.   From Google Play:

[<img src="./badges/Google-Play/Get-It-On-Google-Play-Badge_en.svg" height="80" />](https://play.google.com/store/apps/details?id=com.gentin.connectiq.handsfree) 

2.   If you prefer to not depend on Google Play, you can install the latest version of the app from the following page:

https://grigorye.github.io/handsfree/Installation

## Setup

-   Install the Android app, open it, and toggle all the features on (preferably) - you'll get prompts for the necessary permissions.
-   Check/adjust the list of favorites on your phone.
-   Check https://dontkillmyapp.com for your phone model (the link that should automatically show hints for your phone model is available in About > Troubleshooting > Hints for running apps in background on your phone in Android app).
-   Install the watch app, launch it. It should get the list of the contacts from the phone and you should be ready to go.

# Troubleshooting

It's critical for the companion app to be able to run in background and to be able to receive the requests from the watch. To avoid troubles, I really recommend to take a look at https://dontkillmyapp.com and follow instructions for your specific phone model, to let Handsfree *and* Garmin Connect app run in the background.

See also [optimization for responsiveness](./docs/Optimization.md).

# Contributing

If you want to build it yourself/experiment/play with the source, all the things necessary except the developer keys are stored in the repo.

Regular development should be possible with Android Studio (companion app) and Visual Studio Code (watch app).

For watch app, use **./WatchApp** as the VScode workspace. The default build is configured to produce a watch app. To get a widget build (and hence e.g. get "glance" available for Instinct 2), edit [.vscode/settings.json](WatchApp/.vscode/settings.json) and replace "app.jungle" with "widget.jungle" in monkeyC.jungleFiles setting.

# Publishing

Use AndroidApp/extras/Publishing/bin/bundle-and-reveal for building Android app (would need e.g. GRADLE_EXTRA_ARGS to bind the developer key).

Use WatchApp/build-all for building watch app (would need ../Handsfree-Publishing/keys/developer_key to hold the developer key).


# Disclaimer

I'm neither Garmin nor Android software developer (I'm iOS/ex. macOS developer in my day life though). This is my first and the only pet project that utilizes either of the platforms.
