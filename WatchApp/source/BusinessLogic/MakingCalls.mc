using Toybox.Lang;

(:background)
var callStateIsOwnedByUs as Lang.Boolean = false;

function scheduleCall(phone as Phone) as Void {
    dump("scheduleCallPhone", phone);
    dump("oldCallStateIsOwnedByUs", callStateIsOwnedByUs);
    callStateIsOwnedByUs = true;
    dump("newCallStateIsOwnedByUs", callStateIsOwnedByUs);
    new CallTask(phone).launch();
}