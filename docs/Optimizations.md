# Optimizing for responsiveness

There're a couple settings that speed up the operation/responsiveness of the watch app.

-   **Faster Calls**

    -   **ON** (default): watch app assumes that requests that it sends to the phone succeed, even before it gets a confirmation from the phone. The app indicates such a case by placing "|" around the texts shown. For example, right after selecting a contact to initiate a call, Handsfree will show you "Call in progress" screen, with a contact name, options to Hang Up/Control the sound volume and etc. - those can actually be used right away. For a few seconds, it will show the contact name (e.g. John Doe) like "|John Doe|", then the contact name will be shown as "John Doe".
    -   **OFF** (not recommended): you will not get to the "Call in Progress" screen until the moment when the watch actually receives the confirmation from the phone - that takes a few seconds and may be confusing, because the call in fact may be already in progress even if watch shows "Calling XXX".

-   **Eager Sync**:

    -   **ON** (recommended [^1]): all the changes in recents/favorites/phone state are automatically pushed from phone to the watch, even if you don't open the watch app. All the information is instantly available on the watch when you open the app/bring glance into the view.
        [^1]: It is recommended to turn it on, if you find yourself regularly using Handsfree for calls. Otherwise, especially if you deal *lots of* calls, it may result in wasting battery life for "nothing", though the negative effect should be still minimal.

    -   **OFF** (default): no data is delivered to the watch until you open the app/bring the glance into the view. You *will* observe delay with the glance data not appearing/app data updated from the phone. This is "super power saving mode", basically guaranteeing zero effect on the battery life, at least if your phone is around your watch most of the times.

    Even when the setting is off, the mode is unconditionally activated on opening the app or viewing the app glance, until 5 minutes have passed after returning to the watchface.
    The (Android) companion app makes the mode visible via the icon in front of the Garmin device name:
    
    -   ⚡ Eager sync is active, changes (if any) are actively pushed to the watch.
    -   🟢 Eager sync is not active, the watch is on standby, changes are not actively pushed to the watch.

