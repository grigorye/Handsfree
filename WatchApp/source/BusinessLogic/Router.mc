using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

var router as Router = new Router();

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
                        WatchUi.switchToView(updatedPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof SchedulingCall: {
                        dump("routingToScheduling", true);
                        if (animating) {
                            dump("pushingOutPhones", true);
                            WatchUi.pushView(new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_LEFT);
                        } else {
                            WatchUi.switchToView(new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        }
                        break;
                    }
                    case instanceof CallInProgress: {
                        dump("routingToCallInProgress", true);
                        var phone = (newState as CallInProgress).phone;
                        if (animating) {
                            dump("pushingOutPhones", true);
                            WatchUi.pushView(new CallInProgressView(phone), new CallInProgressViewDelegate(), WatchUi.SLIDE_LEFT);
                        } else {
                            WatchUi.switchToView(new CallInProgressView(phone), new CallInProgressViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        }
                        break;
                    }
                    case instanceof Ringing: {
                        break;
                    }
                    default:
                        fatalError("Unhandled newState");
                }
                break;
            case instanceof SchedulingCall:
                switch (newState) {
                    case instanceof SchedulingCall: {
                        dump("routingToUpdatedScheduledCall", true);
                        WatchUi.switchToView(new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        dump("routingToCallInProgress", true);
                        var phone = (newState as CallInProgress).phone;
                        WatchUi.switchToView(new CallInProgressView(phone), new CallInProgressViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof Idle: {
                        dump("routingToPhones", true);
                        if (animating) {
                            dump("poppingToPhones", true);
                            updatedPhonesView();
                            WatchUi.popView(WatchUi.SLIDE_RIGHT);
                        } else {
                            WatchUi.switchToView(updatedPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        }
                        break;
                    }
                    default:
                        fatalError("Unhandled newState");
                }
                break;
            case instanceof CallInProgress:
                switch (newState) {
                    case instanceof DismissedCallInProgress:
                    case instanceof Idle: {
                        dump("routingToPhones", true);
                        if (animating) {
                            updatedPhonesView();
                            dump("poppingToPhones", true);
                            WatchUi.popView(WatchUi.SLIDE_RIGHT);
                        } else {
                            WatchUi.switchToView(updatedPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        }
                        break;
                    }
                    case instanceof HangingUp: {
                        dump("routingToHangingUp", true);
                        WatchUi.switchToView(new HangingUpView(), new HangingUpViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        dump("routingToNewCallInProgress", true);
                        var phone = (newState as CallInProgress).phone;
                        WatchUi.switchToView(new CallInProgressView(phone), new CallInProgressViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    default:
                        fatalError("Unhandled newState");
                }
                break;
            case instanceof HangingUp:
                switch (newState) {
                    case instanceof HangingUp: {
                        dump("routingToUpdatedHangingUp", true);
                        WatchUi.switchToView(new HangingUpView(), new HangingUpViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        dump("routingToCallInProgress", true);
                        var phone = (newState as CallInProgress).phone;
                        WatchUi.switchToView(new CallInProgressView(phone), new CallInProgressViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof Idle: {
                        dump("routingToPhones", true);
                        if (animating) {
                            (phonesView as PhonesView).updateFromCallState(getCallState());
                            WatchUi.requestUpdate();
                            dump("poppingToPhones", true);
                            WatchUi.popView(WatchUi.SLIDE_RIGHT);
                        } else {
                            WatchUi.switchToView(updatedPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        }
                        break;
                    }
                    default:
                        fatalError("Unhandled newState");
                }
                break;
            default:
                fatalError("Unhandled oldState");
        }
    }

    function updatedPhonesView() as PhonesView {
        if (phonesView == null) {
            phonesView = new PhonesView();
        }
        (phonesView as PhonesView).updateFromCallState(getCallState());
        WatchUi.requestUpdate();
        return phonesView as PhonesView;
    }
}

var animating as Lang.Boolean = false;
var phonesView as PhonesView or Null;
