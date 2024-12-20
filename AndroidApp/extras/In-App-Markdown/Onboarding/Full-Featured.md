# Show phone numbers or contact names for calls

Handsfree can let you see the phone number and contact name for a call, on the watch, like a usual phone. If you want to benefit from that, give it a couple more permissions, in addition to the [essential ones](link://onboarding_essentials).

### [Access your phone call logs](permissions://?manifest=android.permission.READ_CALL_LOG)

To be able to identify the number of an outgoing or incoming call, as well as be able to access your recent calls on the watch, Handsfree needs access to your call logs.

Without the permission, you'll see just "Call in progress" or "Incoming call" instead of number or the contact names. It will not be able to show you recent calls either.

With the permission, Handsfree will be able to show you the number (and probably the contact name, see below), on the watch.

### [Access your contacts](permissions://?manifest=android.permission.READ_CONTACTS)

To be able to match the phone number of a call with a contact name and show it on the watch, Handsfree needs access to your contacts, so that when it observes the call, it can send the matching contact name to show it to you on the watch.

Without the permission, no contact names for calls would be visible to you on the watch.
