# Show phone numbers or contact names for calls

Handsfree can let you see the phone number and contact name for a call, on the watch, like a usual phone. If you want to benefit from that, give it a couple more permissions, in addition to the [essential ones](link://onboarding_essentials).

### [Access your phone call logs](permissions://?manifest=android.permission.READ_CALL_LOG)

To be able to identify the number of a call, Handsfree needs access to your call logs. When it identifies a call, Handsfree sends the phone number to the watch, so you would see it there.

Without the permission, you'll see just "Call in progress" or "Incoming call" instead of number or the contact names.

With the permission, Handsfree will be able to show you the number (and probably the contact name, see below), on the watch.

### [Access your contacts](permissions://?manifest=android.permission.READ_CONTACTS)

To be able to match the phone number of a call with a contact name and show it on the watch, Handsfree needs access to your contacts, so that when it observes the call, it can send the matching contact name to show it to you on the watch.

Without the permission, no contact names for calls would be visible to you on the watch.
