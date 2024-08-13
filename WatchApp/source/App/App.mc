using Toybox.Application;
using Toybox.Background;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Communications;

(:glance, :background)
const L_APP as LogComponent = "app";
(:glance, :background)
const L_APP_LIFE_CYCLE as LogComponent = "app";
(:glance)
const L_APP_INITIAL_VIEW as LogComponent = "app";
(:glance, :background)
const L_APP_STAT as LogComponent = "app";
(:glance, :background)
const L_APP_EXTRA as LogComponent = "app";
(:background)
const L_COMPANION_TRACK as LogComponent = "companionTrack";

(:glance, :background)
class App extends Application.AppBase {

    function initialize() {
        _2(L_APP_LIFE_CYCLE, "initialize");
        _3(L_APP_STAT, "systemStats", systemStatsDumpRep());
        _3(L_APP_EXTRA, "backgroundAppUpdateEnabled", isBackgroundAppUpdateEnabled());
        _3(L_APP, "appType", appType());
        AppBase.initialize();
        _3(L_APP_EXTRA, "getPhoneAppMessageEventRegistered", Background.getPhoneAppMessageEventRegistered());
        Background.registerForPhoneAppMessageEvent();
    }

    function onStart(state as Lang.Dictionary or Null) {
        _3(L_APP, "onStart", state);
        AppBase.onStart(state);
    }

    function onStop(state as Lang.Dictionary or Null) {
        _3(L_APP_LIFE_CYCLE, "activeUiKindOnStop", getActiveUiKind());
        _3(L_APP_LIFE_CYCLE, "onStop", state);
        _3(L_APP_STAT, "systemStats", systemStatsDumpRep());
        AppBase.onStop(state);
    }

    (:typecheck(disableGlanceCheck))
    function getServiceDelegate() as [System.ServiceDelegate] {
        _2(L_APP_EXTRA, "getServiceDelegate");
        return [new BackgroundServiceDelegate()];
    }

    (:typecheck([disableBackgroundCheck, disableGlanceCheck]))
    function onBackgroundData(data as Application.PersistableType) as Void {
        onBackgroundDataImp(data);
        AppBase.onBackgroundData(data);
    }

    (:typecheck([disableGlanceCheck, disableBackgroundCheck]))
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return getInitialViewInApp();
    }

    (:typecheck([disableBackgroundCheck]))
    function getGlanceView() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
        return getGlanceViewInApp();
    }
}

(:glance)
function getGlanceViewInApp() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
    setActiveUiKind(ACTIVE_UI_GLANCE);
    return [new GlanceView()];
}

function willReturnInitialView() as Void {
    setActiveUiKind(ACTIVE_UI_APP);
    onAppDidFinishLaunching();
}

(:widget)
function getInitialViewInApp() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
    willReturnInitialView();
    var view = new WidgetView();
    var delegate = new WidgetViewDelegate();
    trackInitialView("widget", view, delegate);
    return [view, delegate];
}

(:watchApp)
function getInitialViewInApp() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
    willReturnInitialView();
    var view = new CommView();
    trackInitialView("commView", view, null);
    return [view];
}

function deviceSettingsDumpRep(deviceSettings as System.DeviceSettings) as Lang.String {
    return ""
        + Lang.format("monkey: $1$.$2$.$3$", deviceSettings.monkeyVersion) 
        + ", "
        + Lang.format("firmware: $1$", deviceSettings.firmwareVersion)
        + ", "
        + Lang.format("part: $1$", [deviceSettings.partNumber])
        + ", "
        + Lang.format("glanceMode: $1$", [isGlanceModeEnabled()])
        + ", "
        + Lang.format(
            "enhancedReadabilityMode: $1$",
            [(deviceSettings has :isEnhancedReadabilityModeEnabled) ? deviceSettings.isEnhancedReadabilityModeEnabled : "unavailable"]
        );
}

function appWillRouteToMainUI() as Void {
    _2(L_APP, "appWillRouteToMainUI");
}

var routedToMainUI as Lang.Boolean = false;

function appDidRouteToMainUI() as Void {
    if (routedToMainUI) {
        System.error("Already routed to main UI");
    }
    routedToMainUI = true;
    launchCheckInIfNecessary();
}

function launchCheckInIfNecessary() as Void {
    var callState = getCallState();
    if (!(callState instanceof Idle)) {
        _3(L_APP_LIFE_CYCLE, "checkInSkipped.dueToCallState", callState);
    } else {
        if (getCheckInImp() != null) {
            System.error("getCheckInImp() != null");
        }
        getCheckIn().launch();
    }
}

(:widget)
function appDidRouteFromMainUI() as Void {
    _2(L_APP, "appDidRouteFromMainUI");
    setRoutedCallStateImp(null);
    setPhonesViewImp(null);
}

(:widget)
function widgetDidShow() as Void {
    _2(L_APP, "widgetDidShow");
    if (routedToMainUI) {
        routedToMainUI = false;
        appDidRouteFromMainUI();
    }
}

function onAppDidFinishLaunching() as Void {
    _2(L_APP, "onAppDidFinishLaunching");
    _3(L_APP_EXTRA, "deviceSettings", deviceSettingsDumpRep(System.getDeviceSettings()));
    eraseAppDataIfNecessary();
    _3(L_COMPANION_TRACK, "everSeenCompanion", everSeenCompanion());
    (new InAppIncomingMessageDispatcher()).launch();
    var callState = getCallState();
    if (callState instanceof CallInProgress) {
        var phone = (callState as CallInProgress).phone;
        if (isIncomingCallPhone(phone)) {
            startRequestingAttentionIfInApp();
        }
    }
}

function didSeeIncomingMessageWhileRoutedToMainUI() as Void {
    _2(L_APP, "didSeeIncomingMessageWhileRoutedToMainUI");
    var checkIn = getCheckInImp();
    if (checkIn != null) {
        checkIn.remoteResponded();
    }
}

(:background)
function onBackgroundDataImp(data as Application.PersistableType) as Void {
    _3(L_APP_LIFE_CYCLE, "onBackgroundData", data);
    _3(L_APP_STAT, "systemStats", systemStatsDumpRep());
    switch (data) {
        case instanceof Lang.String: {
            switch (data as Lang.String) {
                case "onPhoneAppMessage": {
                    setPhones(loadPhones());
                    var loadedCallState = loadCallState();
                    if (loadedCallState != null) {
                        setCallState(loadedCallState);
                    }
                    var loadedIsHeadsetConnected = loadIsHeadsetConnected();
                    if (loadedIsHeadsetConnected != null) {
                        setIsHeadsetConnected(loadedIsHeadsetConnected);
                    }
                    break;
                }
                default:
                    System.error("Unexpected data");
            }
            break;
        }
        default:
            System.error("Unexpected data type");
    }
}
