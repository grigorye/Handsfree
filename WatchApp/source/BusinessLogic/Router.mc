using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

var routerImp as Router or Null;

function getRouter() as Router {
    if (routerImp == null) {
        routerImp = new Router();
    }
    return routerImp as Router;
}

class Router {
    function initialize() {}

    var updateCounter as Lang.Number = 0;

    function updateRoute() as Void {
        updateCounter = updateCounter + 1;
        dump("updateRoute", updateCounter);
        var oldState = getOldCallState();
        var newState = getCallState();
        dumpCallState("routingOldState", oldState);
        dumpCallState("routingNewState", newState);
        switch (oldState as CallState) {
            case instanceof DismissedCallInProgress:
            case instanceof Idle:
                switch (newState) {
                    case instanceof Idle: {
                        dump("routingToNewPhones", true);
                        switchToView("phones", updatedPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof SchedulingCall: {
                        dump("routingToScheduling", true);
                        dump("pushingOutPhones", true);
                        pushView("scheduling", new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_LEFT);
                        break;
                    }
                    case instanceof CallInProgress: {
                        dump("routingToCallInProgress", true);
                        var phone = (newState as CallInProgress).phone;
                        dump("pushingOutPhones", true);
                        pushView("callInProgress", newCallInProgressView(phone), newCallInProgressViewDelegate(phone), WatchUi.SLIDE_LEFT);
                        break;
                    }
                    default:
                        System.error("Unhandled newState");
                }
                break;
            case instanceof SchedulingCall:
                switch (newState) {
                    case instanceof SchedulingCall: {
                        dump("routingToUpdatedScheduledCall", true);
                        switchToView("scheduling", new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        dump("routingToCallInProgress", true);
                        var phone = (newState as CallInProgress).phone;
                        switchToView("callInProgress", newCallInProgressView(phone), newCallInProgressViewDelegate(phone), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof Idle: {
                        dump("poppingToPhones", true);
                        popToPhones();
                        break;
                    }
                    default:
                        System.error("Unhandled newState");
                }
                break;
            case instanceof CallInProgress:
                switch (newState) {
                    case instanceof DismissedCallInProgress:
                    case instanceof Idle: {
                        dump("poppingToPhones", true);
                        popToPhones();
                        break;
                    }
                    case instanceof HangingUp: {
                        dump("routingToHangingUp", true);
                        pushView("hangingUp", new HangingUpView(newState as HangingUp), new HangingUpViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        dump("routingToNewCallInProgress", true);
                        var phone = (newState as CallInProgress).phone;
                        popView(WatchUi.SLIDE_IMMEDIATE);
                        pushView("callInProgress", newCallInProgressView(phone), newCallInProgressViewDelegate(phone), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    default:
                        System.error("Unhandled newState");
                }
                break;
            case instanceof HangingUp:
                switch (newState) {
                    case instanceof HangingUp: {
                        dump("routingToUpdatedHangingUp", true);
                        switchToView("hangingUp", new HangingUpView(newState as HangingUp), new HangingUpViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        dump("routingToCallInProgress", true);
                        var phone = (newState as CallInProgress).phone;
                        switchToView("callInProgress", newCallInProgressView(phone), newCallInProgressViewDelegate(phone), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof Idle: {
                        dump("poppingToPhones", true);
                        popToPhones();
                        break;
                    }
                    default:
                        System.error("Unhandled newState");
                }
                break;
            default:
                System.error("Unhandled oldState");
        }
    }

    function updatedPhonesView() as PhonesView {
        var phonesView = getPhonesView();
        phonesView.updateFromCallState(getCallState());
        WatchUi.requestUpdate();
        return phonesView;
    }

    function popToPhones() as Void {
        if (isExitToSystemAfterCallCompletionEnabled()) {
            popView(WatchUi.SLIDE_IMMEDIATE);
            exitToSystemFromPhonesView();
        } else {
            updatedPhonesView();
            popView(WatchUi.SLIDE_RIGHT);
        }
    }
}

function exitToSystemFromPhonesView() as Void {
    dump("exitingToSystemFromPhonesView", true);
    if (!topViewIs("phones")) {
        dumpViewStack("messedUpViewStack");
        System.error("viewStackIsMessedUp");
    }
    popView(WatchUi.SLIDE_IMMEDIATE);
    exitToSystemFromCommView();
}

function exitToSystemFromCommView() as Void {
    dump("exitingToSystemFromCommView", true);
    if (!topViewIs("commView")) {
        dumpViewStack("messedUpViewStack");
        System.error("viewStackIsMessedUp");
    }
    popView(WatchUi.SLIDE_IMMEDIATE);
}
