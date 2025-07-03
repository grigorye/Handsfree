**TL;DR**: Make calls via your Garmin device without taking your phone out of your pocket.

###### **Beta testers wanted!**

**If you're interested in joining the beta, please reach out to me or send a request to join the [dedicated Google group](https://groups.google.com/g/handsfree-beta) - I'd really appreciate that.**

# Why

For one reason or another, I often find myself wearing a Bluetooth headset connected to my Android phone (specifically, hearing aids in my case). The same phone is connected to my Garmin watch.

The watch (one of the best in the world, if you ask me) allows me to control Music, Podcasts and, among other things, *answer and control incoming calls* on the phone. What it does not allow me to do yet is *initiate and control outgoing calls*. Handsfree fills that gap.

# Features

-   [Call control](./docs/Call-Control.md)
-   [Outgoing calls](./docs/Outgoing-Calls.md)
-   [Incoming calls](./docs/Incoming-Calls.md)
-   [Customizable *continuous* vibration on incoming calls](./docs/Vibration.md) (Fenix 7 only)
-   [Recent contacts](./docs/Recents.md)
-   [Missed calls](./docs/Missed-Calls.md)
-   [In-call audio *volume* control, microphone muting](./docs/In-Call-Audio.md)
-   [Headset status](./docs/Headset-Status.md)
-   [Speakerphone control](./docs/Speaker-Phone.md)
-   [Seamless syncing](./docs/Syncing.md)
-   [Glance view](./docs/Glance.md)

# How

The solution has two components: the app running on the watch and the companion app running on an Android phone.

## Companion (Android) app

Acts like a (dumb) relay between the watch and the rest of the phone:

-   Serves your requests from the watch, e.g. directing the phone to initiate or hangup a call
-   Sends the updates to the watch so that you see calls in progress
-   Sends the names/phone numbers from a preselected contact group (currently, starred contacts) to the watch so that you can select a number to dial
-   Sends call history to the watch
-   Sends headset/microphone status to the watch

## Garmin watch app

-   Shows the list of starred contacts provided by companion app
-   Lets you start and control outgoing calls for selected contact numbers
-   Lets you control calls in progress, even if they *weren't* initiated from the watch
-   Shows Bluetooth headset connection status in the app/glance: # symbol in the title indicates that headset is not connected/will not be used if you make/accept a call (in that case speakerphone is used for outgoing calls, while earpeace is used for incoming calls).

# Demo

https://youtu.be/xiZ8kEoOO0Q

# Getting started

## Requirements

-   Garmin watch or bike computer (see [Connect IQ app page](https://apps.garmin.com/apps/73107243-f322-4cf2-bb3d-78f2a4ee8920?tid=1) for supported models)
-   Android phone (currently limited to Android 10 or later) with Garmin Connect app installed and connected to the watch
-   iPhones are not supported (I could not find a way to drive calls there without explicit user confirmation for each call).

## Installation

##### [Handsfree app](https://apps.garmin.com/en-US/apps/73107243-f322-4cf2-bb3d-78f2a4ee8920) for Garmin watch

[<img src="./badges/Connect-IQ/Connect-IQ-Badge_White.svg" alt="available-connect-iq-badge" height="88"/>](https://apps.garmin.com/en-US/apps/73107243-f322-4cf2-bb3d-78f2a4ee8920)

##### Handsfree companion app for Android phone

There are currently a couple ways to obtain the Android app.

1.   From Google Play:

[<img src="./badges/Google-Play/Get-It-On-Google-Play-Badge_en.svg" height="80" />](https://play.google.com/store/apps/details?id=com.gentin.connectiq.handsfree) 

2.   If you prefer to not depend on Google Play, you can install the latest version of the app from the following page:

https://grigorye.github.io/handsfree/Installation

## Setup

-   Install the Android app, open it, and toggle all features on (preferably) - you'll be prompted for the necessary permissions.
-   Check/adjust list of favorite contacts on your phone.
-   Check https://dontkillmyapp.com for your phone model (the link that should automatically show hints for your device is available in "About > Troubleshooting > Hints for running apps in background" in the Android app).
-   Install the watch app and launch it. It should retrieve the list of contacts from your phone and you should be ready to go.

# Troubleshooting

It's critical for the companion app to be allowed to run in background and receive the requests from the watch. To avoid issues, I highly recommend checking https://dontkillmyapp.com and following instructions for your specific phone model to ensure Handsfree *and* Garmin Connect can run in the background.

See also [optimization for responsiveness](./docs/Optimizations.md).

# Contributing

If you want to build, experiment with, or modify the source, everything necessary (except the developer keys) is stored in the repo.

Regular development should be possible with Android Studio (companion app) and Visual Studio Code (watch app).

For watch app, use **./WatchApp** as the VScode workspace. The default build produces a watch app. To build a widget (and thus get "glance" available for Instinct 2), edit [.vscode/settings.json](WatchApp/.vscode/settings.json) and replace "app.jungle" with "widget.jungle" in the monkeyC.jungleFiles setting.

# Publishing

Use AndroidApp/extras/Publishing/bin/bundle-and-reveal to build the Android app (requires GRADLE_EXTRA_ARGS to bind the developer key).

Use WatchApp/build-all to build the watch app (requires ../Handsfree-Publishing/keys/developer_key to hold the developer key).


# Disclaimer

I'm neither a Garmin nor an Android software developer (I'm an iOS/ex-macOS developer in my day life though). This is my first and only pet project that utilizes either of these platforms.
