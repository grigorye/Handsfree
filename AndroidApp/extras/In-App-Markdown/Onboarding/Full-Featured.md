# Run most of the phone features on the watch

With Handsfree you can completely offload most of the phone call management to your watch: besides letting you make outgoing calls, Handsfree can show you the phone numbers and the names of the contacts for any calls in progress. If you want to benefit from that, you need to give Handsfree a couple more permissions, in addition to those required for [bare minimum outgoing calls](link://onboarding_outgoing_calls):

### [Access your phone call logs](permissions://?manifest=android.permission.READ_CALL_LOG)

To be able to identify the number of a call in progress, Handsfree needs access to your call logs. When it identifies a call in progress, Handsfree sends the phone number to the watch, so that it's displayed there.

Without this permission, you'll see "Unreadable" instead of the number or the contact name for calls in progress.

With this permission, Handsfree will be able to show you the number (and probably the contact name, see below), on the watch.

### [Access your contacts](permissions://?manifest=android.permission.READ_CONTACTS)

To be able to match the phone number of call in progress with a contact name and show it on the watch, Handsfree needs access to your contacts, so that when it identifies a call in progress, it can send the matching contact name to be displayed on the watch.

Without this permission, only the phone number will be visible on the watch (and that is only if you gave access to call logs to Handsfree).
