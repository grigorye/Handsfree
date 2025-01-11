# Allow recent calls

Handsfree lets you see and make calls to recently contacted parties, as well as track missed calls, on the watch. To allow that, give the app a couple more permissions, in addition to the [essential ones](link://onboarding_essentials).

Currently the number of the recent contacts is limited to 5.

### [Access your phone call logs](permissions://?manifest=android.permission.READ_CALL_LOG)

To show your recent calls on the watch, Handsfree needs access to your call logs.

Without the permission, recent calls won't be shown.

With the permission, Handsfree will be able to show you the number (and probably the contact name, see below) and call back your recent/missed calls, from the watch.

### [Access your contacts](permissions://?manifest=android.permission.READ_CONTACTS)

To be able to match the phone number of a call with a contact name and show it on the watch, Handsfree needs access to your contacts, so that when notices a recent call, it can send the matching contact name to show it to you on the watch.

Without the permission, no contact names for calls would be visible to you on the watch.
