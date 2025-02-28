# Show caller info

Handsfree can let you see the phone number and contact name for a call, on the watch, like a normal phone. If you want to benefit from that for the calls that you did not initiate on the watch, give the app a couple more permissions, in addition to the [essential ones](link://onboarding_essentials).

### [Access your phone call logs](permissions://?manifest=android.permission.READ_CALL_LOG)

To be able to identify the phone number for a call, Handsfree needs access to your call logs.

With the permission, Handsfree will be able to show you the phone number (and probably the contact name, see below), on the watch.

Without the permission, Handsfree will display a generic message like "Call in Progress".

### [Access your contacts](permissions://?manifest_optional=android.permission.READ_CONTACTS)

To be able to match the phone number of a call with a contact name and show it on the watch, Handsfree needs access to your contacts, so that when it observes the call, it can send the matching contact name to show it to you on the watch.

Without the permission, no contact names for the calls will be visible.
