import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

const L_ROUTER as LogComponent = "router";

var routerImp as Router or Null;

function getRouter() as Router {
    if (routerImp == null) {
        routerImp = new Router();
    }
    return routerImp as Router;
}

class Router {
    function initialize() {}

    private var updateCounter as Lang.Number = 0;

    function updateRoute() as Void {
        updateCounter = updateCounter + 1;
        if (debug) { _3(L_ROUTER, "updateRoute", updateCounter); }
        var oldState = getRoutedCallState();
        var newState = getCallState();
        if (debug) { _3(L_ROUTER, "oldState", oldState); }
        if (debug) { _3(L_ROUTER, "newState", newState); }
        setRoutedCallStateImp(newState);
        switch (oldState as CallState) {
            case instanceof DismissedCallInProgress:
            case instanceof Idle:
                switch (newState) {
                    case instanceof Idle: {
                        if (debug) { _2(L_ROUTER, "fakeRoutingToNewPhones"); }
                        break;
                    }
                    case instanceof SchedulingCall: {
                        if (debug) { _2(L_ROUTER, "routingToScheduling"); }
                        if (debug) { _2(L_ROUTER, "pushingOutPhones"); }
                        pushView("scheduling", new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_LEFT);
                        break;
                    }
                    case instanceof CallInProgress: {
                        if (debug) { _2(L_ROUTER, "routingToCallInProgress"); }
                        var phone = (newState as CallInProgress).phone;
                        if (debug) { _3(L_ROUTER, "pushingOutPhones", true); }
                        pushView("callInProgress", new CallInProgressView(phone, isOptimisticCallState(newState)), new CallInProgressViewDelegate(phone), WatchUi.SLIDE_LEFT);
                        break;
                    }
                    default:
                        System.error("Unhandled newState");
                }
                break;
            case instanceof SchedulingCall:
                switch (newState) {
                    case instanceof SchedulingCall: {
                        if (debug) { _2(L_ROUTER, "routingToUpdatedScheduledCall"); }
                        switchToView("scheduling", new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        if (debug) { _2(L_ROUTER, "routingToCallInProgress"); }
                        var phone = (newState as CallInProgress).phone;
                        switchToView("callInProgress", new CallInProgressView(phone, isOptimisticCallState(newState)), new CallInProgressViewDelegate(phone), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof Idle: {
                        if (debug) { _2(L_ROUTER, "poppingFromCallView"); }
                        popFromCallView();
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
                        if (debug) { _2(L_ROUTER, "poppingFromCallView"); }
                        popFromCallView();
                        break;
                    }
                    case instanceof CallActing: {
                        if (debug) { _2(L_ROUTER, "routingToCallActing"); }
                        pushView("callActing", new CallActingView(newState as CallActing), new CallActingViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        if (debug) { _2(L_ROUTER, "updatingForNewCallInProgress"); }
                        var phone = (newState as CallInProgress).phone;
                        var view = viewWithTag("callInProgress") as CallInProgressView | Null;
                        if (view != null) {
                            view.updateFromPhone(phone, isOptimisticCallState(newState));
                        }
                        break;
                    }
                    default:
                        System.error("Unhandled newState");
                }
                break;
            case instanceof CallActing:
                switch (newState) {
                    case instanceof CallActing: {
                        if (debug) { _2(L_ROUTER, "routingToUpdatedCallActing"); }
                        switchToView("callActing", new CallActingView(newState as CallActing), new CallActingViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        if (debug) { _2(L_ROUTER, "routingToCallInProgress"); }
                        var phone = (newState as CallInProgress).phone;
                        switchToView("callInProgress", new CallInProgressView(phone, isOptimisticCallState(newState)), new CallInProgressViewDelegate(phone), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof Idle: {
                        if (debug) { _2(L_ROUTER, "poppingFromCallView"); }
                        popFromCallView();
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

    function popFromCallView() as Void {
        if (AppSettings.isExitToSystemAfterCallCompletionEnabled) {
            exitToSystemFromCurrentView();
        } else {
            popView(WatchUi.SLIDE_RIGHT);
        }
    }
}

function exitToSystemFromCurrentView() as Void {
    if (debug) { _3(L_ROUTER, "exitingToSystemFromCurrentView", viewStackTags()); }
    while (!topViewIs("commView")) {
        popView(WatchUi.SLIDE_IMMEDIATE);
    }
    exitToSystemFromCommView();
}

function exitToSystemFromCommView() as Void {
    if (viewDebug) { _2(L_ROUTER, "exitingToSystemFromCommView"); }
    if (!topViewIs("commView")) {
        dumpViewStack("messedUpViewStack");
        System.error("viewStackIsMessedUp");
    }
    if (viewStackTagsEqual(["commView"])) {
        if (viewDebug) { _2(L_ROUTER, "willSystemExit"); }
        if (tweakingForSystemExit) {
            System.exit();
        }
        if (viewDebug) { _2(L_ROUTER, "systemExitDidNotExit"); }
        exiting = true;
    } else {
        if (viewDebug) { _3(L_ROUTER, "poppingUpAsCommViewIsNotTop", viewStackTags()); }
    }
    popView(WatchUi.SLIDE_IMMEDIATE);
}

// Workaround for System.exit() treated as non-returning (while it is, in some cases).
var tweakingForSystemExit as Lang.Boolean = true;

const viewDebug as Lang.Boolean = true;
