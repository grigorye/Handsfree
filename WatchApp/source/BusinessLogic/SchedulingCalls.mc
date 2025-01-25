import Toybox.Lang;

const L_SCHEDULE_CALL_DEBUG as LogComponent = "scheduleCall";

module Req {

function scheduleCall(phone as Phone) as Void {
    if (debug) { _3(L_SCHEDULE_CALL, "phone", phone); }
    new ScheduleCallTask(phone).launch();
}

}