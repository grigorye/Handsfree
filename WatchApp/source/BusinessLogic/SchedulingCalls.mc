using Toybox.Lang;

(:background)
var callStateIsOwnedByUs as Lang.Boolean = false;

const L_SCHEDULE_CALL_DEBUG as LogComponent = "scheduleCall";

function scheduleCall(phone as Phone) as Void {
    _([L_SCHEDULE_CALL, "phone", phone]);
    _([L_SCHEDULE_CALL_DEBUG, "oldCallStateIsOwnedByUs", callStateIsOwnedByUs]);
    callStateIsOwnedByUs = true;
    _([L_SCHEDULE_CALL_DEBUG, "newCallStateIsOwnedByUs", callStateIsOwnedByUs]);
    new ScheduleCallTask(phone).launch();
}