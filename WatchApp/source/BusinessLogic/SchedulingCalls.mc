using Toybox.Lang;

(:background)
var callStateIsOwnedByUs as Lang.Boolean = false;

const L_SCHEDULE_CALL_DEBUG as LogComponent = "scheduleCall";

function scheduleCall(phone as Phone) as Void {
    _3(L_SCHEDULE_CALL, "phone", phone);
    _3(L_SCHEDULE_CALL_DEBUG, "oldCallStateIsOwnedByUs", callStateIsOwnedByUs);
    callStateIsOwnedByUs = true;
    _3(L_SCHEDULE_CALL_DEBUG, "newCallStateIsOwnedByUs", callStateIsOwnedByUs);
    new ScheduleCallTask(phone).launch();
}