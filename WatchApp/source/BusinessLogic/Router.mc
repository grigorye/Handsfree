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
                        VT.pushView(V_scheduling, new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_LEFT);
                        break;
                    }
                    case instanceof CallInProgress: {
                        if (debug) { _2(L_ROUTER, "routingToCallInProgress"); }
                        var phone = (newState as CallInProgress).phone;
                        if (debug) { _3(L_ROUTER, "pushingOutPhones", true); }
                        VT.popToView(V_comm, WatchUi.SLIDE_IMMEDIATE);
                        VT.pushView(V_callInProgress, new CallInProgressView(phone, isOptimisticCallState(newState)), new CallInProgressViewDelegate(phone), WatchUi.SLIDE_LEFT);
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
                        VT.switchToView(V_scheduling, new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        if (debug) { _2(L_ROUTER, "routingToCallInProgress"); }
                        var phone = (newState as CallInProgress).phone;
                        VT.popToView(V_comm, WatchUi.SLIDE_IMMEDIATE);
                        VT.pushView(V_callInProgress, new CallInProgressView(phone, isOptimisticCallState(newState)), new CallInProgressViewDelegate(phone), WatchUi.SLIDE_IMMEDIATE);
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
                        VT.pushView(V_callActing, new CallActingView(newState as CallActing), new CallActingViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        if (debug) { _2(L_ROUTER, "updatingForNewCallInProgress"); }
                        var phone = (newState as CallInProgress).phone;
                        var existingViewStackEntry = VT.viewStackEntryWithTag(V_callInProgress);
                        if (existingViewStackEntry != null) {
                            var view = existingViewStackEntry.view as CallInProgressView;
                            var delegate = existingViewStackEntry.delegate as CallInProgressViewDelegate;
                            view.updateFromPhone(phone, isOptimisticCallState(newState));
                            delegate.phone = phone;
                        } else {
                            VT.popToView(V_comm, WatchUi.SLIDE_IMMEDIATE);
                            var newCallInProgressView = new CallInProgressView(phone, isOptimisticCallState(newState));
                            VT.pushView(V_callInProgress, newCallInProgressView, new CallInProgressViewDelegate(phone), WatchUi.SLIDE_LEFT);
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
                        VT.switchToView(V_callActing, new CallActingView(newState as CallActing), new CallActingViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        if (debug) { _2(L_ROUTER, "routingToCallInProgress"); }
                        var phone = (newState as CallInProgress).phone;
                        var existingViewStackEntry = VT.viewStackEntryWithTag(V_callInProgress);
                        if (existingViewStackEntry != null) {
                            var view = existingViewStackEntry.view as CallInProgressView;
                            var delegate = existingViewStackEntry.delegate as CallInProgressViewDelegate;
                            view.updateFromPhone(phone, isOptimisticCallState(newState));
                            delegate.phone = phone;
                            do {
                                VT.popView(WatchUi.SLIDE_IMMEDIATE);
                            } while (!VT.topViewIs(V_callInProgress));
                        } else {
                            VT.popToView(V_comm, WatchUi.SLIDE_IMMEDIATE);
                            VT.pushView(V_callInProgress, new CallInProgressView(phone, isOptimisticCallState(newState)), new CallInProgressViewDelegate(phone), WatchUi.SLIDE_IMMEDIATE);
                        }
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
            VT.popView(WatchUi.SLIDE_RIGHT);
        }
    }
}

function exitToSystemFromCurrentView() as Void {
    if (debug) { _3(L_ROUTER, "exitingToSystemFromCurrentView", VT.viewStackTags()); }
    while (!VT.topViewIs(V_comm)) {
        VT.popView(WatchUi.SLIDE_IMMEDIATE);
    }
    exitToSystemFromCommView();
}

function exitToSystemFromCommView() as Void {
    if (viewDebug) { _2(L_COMM_VIEW, "exitingToSystemFromCommView"); }
    if (!VT.topViewIs(V_comm)) {
        VT.dumpViewStack("messedUpViewStack");
        System.error("viewStackIsMessedUp");
    }
    if (VT.viewStackTagsEqual([V_comm])) {
        if (viewDebug) { _2(L_COMM_VIEW, "willSystemExit"); }
        if (tweakingForSystemExit) {
            System.exit();
        }
        if (viewDebug) { _2(L_COMM_VIEW, "systemExitDidNotExit"); }
        exiting = true;
    } else {
        if (viewDebug) { _3(L_COMM_VIEW, "poppingUpAsCommViewIsNotTop", VT.viewStackTags()); }
    }
    VT.popView(WatchUi.SLIDE_IMMEDIATE);
}
