# Outgoing calls

Besides the essential functionality, Handsfree lets you make outgoing calls from the watch for your [starred contacts](contacts://starred), by redirecting your requests from the watch to the default phone application.

Beware that even though you can open Contacts app/see the starred contacts with the above link, Handsfree itself has no access to the list until you give it the permission.

If you want to use outgoing calls on your watch, you need to give Handsfree a few permissions, **in addition** to those required for the [bare minimum](link://onboarding_essentials) functionality:

### [Display over other apps](permissions://?draw_overlays)

To be able to make calls via the standard phone app while running in the background, Handsfree needs the permission to display over other apps.

Without the permission, Handsfree will not be able to make calls when it is not the frontmost application or when the phone is locked. This permission is not necessary for observing or hanging up calls in progress though.

### [Access your contacts](permissions://?manifest=android.permission.READ_CONTACTS)

To let you see the list of the starred contacts that you can use for outgoing calls on your watch on your watch, Handsfree needs permission to access your contacts. Given the permission, Handsfree sends the contact names and phone numbers to the watch. Handsfree never reads nor sends any other contact information to anywhere.

Without this permission, the (starred) contacts won't be available on the watch, and hence it will not be possible to dial the contacts from the watch.

