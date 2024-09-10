using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

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
        _3(L_ROUTER, "updateRoute", updateCounter);
        var oldState = getRoutedCallState();
        var newState = getCallState();
        _3(L_ROUTER, "oldState", oldState);
        _3(L_ROUTER, "newState", newState);
        setRoutedCallStateImp(newState);
        switch (oldState as CallState) {
            case instanceof DismissedCallInProgress:
            case instanceof Idle:
                switch (newState) {
                    case instanceof Idle: {
                        _2(L_ROUTER, "routingToNewPhones");
                        switchToView("phones", updatedPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof SchedulingCall: {
                        _2(L_ROUTER, "routingToScheduling");
                        _2(L_ROUTER, "pushingOutPhones");
                        pushView("scheduling", new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_LEFT);
                        break;
                    }
                    case instanceof CallInProgress: {
                        _2(L_ROUTER, "routingToCallInProgress");
                        var phone = (newState as CallInProgress).phone;
                        _3(L_ROUTER, "pushingOutPhones", true);
                        pushView("callInProgress", new CallInProgressView(phone), new CallInProgressViewDelegate(phone), WatchUi.SLIDE_LEFT);
                        break;
                    }
                    default:
                        System.error("Unhandled newState");
                }
                break;
            case instanceof SchedulingCall:
                switch (newState) {
                    case instanceof SchedulingCall: {
                        _2(L_ROUTER, "routingToUpdatedScheduledCall");
                        switchToView("scheduling", new SchedulingCallView(newState as SchedulingCall), new SchedulingCallViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        _2(L_ROUTER, "routingToCallInProgress");
                        var phone = (newState as CallInProgress).phone;
                        switchToView("callInProgress", new CallInProgressView(phone), new CallInProgressViewDelegate(phone), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof Idle: {
                        _2(L_ROUTER, "poppingFromCallView");
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
                        _2(L_ROUTER, "poppingFromCallView");
                        popFromCallView();
                        break;
                    }
                    case instanceof CallActing: {
                        _2(L_ROUTER, "routingToCallActing");
                        pushView("callActing", new CallActingView(newState as CallActing), new CallActingViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        _2(L_ROUTER, "routingToNewCallInProgress");
                        var phone = (newState as CallInProgress).phone;
                        popView(WatchUi.SLIDE_IMMEDIATE);
                        pushView("callInProgress", new CallInProgressView(phone), new CallInProgressViewDelegate(phone), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    default:
                        System.error("Unhandled newState");
                }
                break;
            case instanceof CallActing:
                switch (newState) {
                    case instanceof CallActing: {
                        _2(L_ROUTER, "routingToUpdatedCallActing");
                        switchToView("callActing", new CallActingView(newState as CallActing), new CallActingViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof CallInProgress: {
                        _2(L_ROUTER, "routingToCallInProgress");
                        var phone = (newState as CallInProgress).phone;
                        switchToView("callInProgress", new CallInProgressView(phone), new CallInProgressViewDelegate(phone), WatchUi.SLIDE_IMMEDIATE);
                        break;
                    }
                    case instanceof Idle: {
                        _2(L_ROUTER, "poppingFromCallView");
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

    function updatedPhonesView() as PhonesView {
        var phonesView = getPhonesView();
        phonesView.updateFromCallState(getCallState());
        WatchUi.requestUpdate();
        return phonesView;
    }

    function popFromCallView() as Void {
        if (AppSettings.isExitToSystemAfterCallCompletionEnabled) {
            exitToSystemFromCurrentView();
        } else {
            updatedPhonesView();
            popView(WatchUi.SLIDE_RIGHT);
        }
    }
}

function exitToSystemFromCurrentView() as Void {
    _3(L_ROUTER, "exitingToSystemFromCurrentView", viewStackTags());
    while (!topViewIs("mainMenu")) {
        popView(WatchUi.SLIDE_IMMEDIATE);
    }
    exitToSystemFromMainMenu();
}

function exitToSystemFromMainMenu() as Void {
    _2(L_ROUTER, "exitingToSystemFromMainMenu");
    if (!topViewIs("mainMenu")) {
        dumpViewStack("messedUpViewStack");
        System.error("viewStackIsMessedUp");
    }
    popView(WatchUi.SLIDE_IMMEDIATE);
    exitToSystemFromCommView();
}

function exitToSystemFromCommView() as Void {
    _2(L_ROUTER, "exitingToSystemFromCommView");
    if (!topViewIs("commView")) {
        dumpViewStack("messedUpViewStack");
        System.error("viewStackIsMessedUp");
    }
    if (viewStackTagsEqual(["commView"])) {
        System.exit();
    }
    popView(WatchUi.SLIDE_IMMEDIATE);
}
