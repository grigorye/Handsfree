# Run essentials

As a bare minimum, Handsfree lets you observe and hangup calls in progress, without sharing any personal information with the watch. The only information that is shared is the fact that there's an unidentified call in progress.

If you want to benefit from the minimum functionality of Handsfree, you need to give it a few essential permissions:

### [Make and manage calls](permissions://?manifest=android.permission.CALL_PHONE,android.permission.ANSWER_PHONE_CALLS,android.permission.READ_PHONE_STATE)

To be able to observe and hangup calls from your watch, Handsfree needs permission from you to make and manage calls.

Without the permission, Handsfree will have very little use, because it won't be able to do much with the calls on the phone for you.

### [Always run in background](permissions://?battery_optimization)

To be able to serve your requests while it's not the frontmost application, Handsfree needs the permission to always run in background.

Without the permission, you'll still be able to use it in foreground, but it will be stopped by the system soon after you switch to other apps.

### [Send you notifications](permissions://?manifest=android.permission.POST_NOTIFICATIONS)

To be able to serve your request while working in background, Handsfree needs the permission to show you a notification. This is a measure for you to be sure that it's running in the background/awaiting for your requests from the watch. It also shows you a bit of current status of the connection to your watch.

Besides the above permissions, to let Handsfree run without interruptions, it's **strongly** recommended to take a look at **[known hints for running Android apps in background, on your particular phone model](do://doki).**

