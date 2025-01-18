# Allow incoming calls

Handsfree lets you show and accept the incoming calls on the watch. To allow that, give the app a couple more permissions, in addition to the [essential ones](link://onboarding_essentials).

### [Access your phone call logs](permissions://?manifest=android.permission.READ_CALL_LOG)

To be able to identify the number for an incoming call, Handsfree needs access to your call logs.

Without the permission, for an incoming call, Handsfree will show just "Call in progress" or "Incoming call" instead of the phone number or the contact name, on the watch.

With the permission, Handsfree will be able to show you the number (and probably the contact name, see below) on the watch.

### [Access your contacts](permissions://?manifest_optional=android.permission.READ_CONTACTS)

To be able to match the phone number of a call with a contact name and show it on the watch, Handsfree needs access to your contacts, so that when it observes the call, it can send the matching contact name to show it to you on the watch.

Without the permission, no contact names for calls would be visible to you on the watch.

## On the watch

When enabled, Handsfree forwards your calls to the watch, so you can see an incoming call *when the watch app is active*.

To actually **get alerted** (or not) about an incoming call *when the watch app is not active*, toggle "Incoming Calls" in the app settings.

<img src="./badges/Watch/Settings-Incoming-Calls.jpg" alt="Settings-Incoming-Calls" style="zoom:50%;" />
