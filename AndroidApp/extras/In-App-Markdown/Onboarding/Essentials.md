# Control calls from the watch

As a bare minimum, Handsfree lets you observe and hangup calls in progress, without sharing any personal information with the watch. The only information that is shared is the fact that there's an unidentified call in progress.

To provide this minimum functionality, Handsfree needs a few essential permissions from you.

### [Make and manage calls](permissions://?manifest=android.permission.CALL_PHONE,android.permission.ANSWER_PHONE_CALLS,android.permission.READ_PHONE_STATE)

To be able to observe and hangup calls from your watch, Handsfree needs the permission from you to make and manage calls.

Without the permission, Handsfree won't be able to perform much of its job, as it won't be able to see a call in progress to show you the call status on the watch, neither it would be able to hangup a call on your request from the watch.

### [Always run in background](permissions://?battery_optimization)

To be able to serve your requests while it's not the frontmost application, Handsfree needs the permission to always run in background.

Without the permission, you'll still be able to use it while it's in the foreground, but it will be stopped by the system soon after you switch to other apps or e.g. lock your phone.

### [Send you notifications](permissions://?manifest=android.permission.POST_NOTIFICATIONS)

To be able to serve your request while working in background, Handsfree needs the permission to show you a notification. This is a measure for you to be sure that it's running in the background/awaiting for your requests from the watch. It also shows you a bit of current status of the connection to your watch.

Without the permission, the system will stop Handsfree soon after it switches to the background.

## Running it in the background

Besides the above permissions, to let Handsfree run without interruptions, check **[the known hints for running Android apps in background, on your particular phone model](do://doki).**

