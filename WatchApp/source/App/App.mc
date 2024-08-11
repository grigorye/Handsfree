using Toybox.Application;
using Toybox.Background;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Communications;

(:glance, :background)
const L_APP as LogComponent = new LogComponent("app", false);
(:glance, :background)
const L_APP_LIFE_CYCLE as LogComponent = new LogComponent("app", false);
(:glance, :background)
const L_APP_INITIAL_VIEW as LogComponent = new LogComponent("app", false);
(:glance, :background)
const L_APP_STAT as LogComponent = new LogComponent("app", false);
(:glance, :background)
const L_APP_EXTRA as LogComponent = new LogComponent("app", false);
(:glance, :background)
const L_COMPANION_TRACK as LogComponent = new LogComponent("companionTrack", false);

(:glance, :background)
class App extends Application.AppBase {

    var backgroundServiceEnabled as Lang.Boolean;
    
    function initialize() {
        _([L_APP_LIFE_CYCLE, "initialize"]);
        _([L_APP_EXTRA, "deviceSettings", deviceSettingsDumpRep(System.getDeviceSettings())]);
        _([L_APP_STAT, "systemStats", systemStatsDumpRep()]);
        _([L_APP_EXTRA, "backgroundAppUpdateEnabled", isBackgroundAppUpdateEnabled()]);
        _([L_APP, "appType", appType()]);
        _([L_COMPANION_TRACK, "everSeenCompanion", everSeenCompanion()]);
        Application.AppBase.initialize();
        backgroundServiceEnabled = isBackgroundServiceEnabled();
        _([L_APP_EXTRA, "backgroundServiceEnabled", backgroundServiceEnabled]);
        _([L_APP_EXTRA, "getPhoneAppMessageEventRegistered", Background.getPhoneAppMessageEventRegistered()]);
        if (backgroundServiceEnabled) {
            Background.registerForPhoneAppMessageEvent();
        } else {
            Background.deletePhoneAppMessageEvent();
        }
    }

    function onStart(state as Lang.Dictionary or Null) {
        _([L_APP, "onStart", state]);
        Application.AppBase.onStart(state);
    }

    function onStop(state as Lang.Dictionary or Null) {
        _([L_APP_LIFE_CYCLE, "activeUiKindOnStop", getActiveUiKind()]);
        _([L_APP_LIFE_CYCLE, "onStop", state]);
        _([L_APP_STAT, "systemStats", systemStatsDumpRep()]);
        Application.AppBase.onStop(state);
    }

    (:background, :typecheck(disableGlanceCheck))
    function getServiceDelegate() as [System.ServiceDelegate] {
        _([L_APP_EXTRA, "getServiceDelegate"]);
        if (!backgroundServiceEnabled) {
            return [new DummyServiceDelegate()];
        }
        return [new BackgroundServiceDelegate()];
    }

    function onBackgroundData(data as Application.PersistableType) as Void {
        onBackgroundDataImp(data);
        Application.AppBase.onBackgroundData(data);
    }

    (:typecheck([disableGlanceCheck, disableBackgroundCheck]))
    function getInitialView() {
        _([L_APP_INITIAL_VIEW, "getInitialView"]);
        eraseAppDataIfNecessary();
        var inWidgetMode = isInWidgetMode();
        _([L_APP_EXTRA, "inWidgetMode", inWidgetMode]);
        setActiveUiKind(ACTIVE_UI_APP);
        onAppDidFinishLaunching();
        if (inWidgetMode) {
            var view = new WidgetView();
            var delegate = new WidgetViewDelegate();
            trackInitialView("widget", view, delegate);
            return [view, delegate];
        } else {
            var view = new CommView();
            trackInitialView("commView", view, null);
            return [view];
        }
    }

    (:glance)
    function getGlanceView() {
        _([L_APP_INITIAL_VIEW, "getGlanceView"]);
        setActiveUiKind(ACTIVE_UI_GLANCE);
        onAppDidFinishLaunching();
        return [new GlanceView()];
    }
}

(:glance, :background)
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
    _([L_APP, "appWillRouteToMainUI"]);
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
        _([L_APP_LIFE_CYCLE, "checkInSkipped.dueToCallState", callState]);
    } else {
        if (getCheckInImp() != null) {
            System.error("getCheckInImp() != null");
        }
        getCheckIn().launch();
    }
}

(:widget)
function appDidRouteFromMainUI() as Void {
    _([L_APP, "appDidRouteFromMainUI"]);
    setRoutedCallStateImp(null);
    setPhonesViewImp(null);
}


(:widget)
function widgetDidShow() as Void {
    _([L_APP, "widgetDidShow"]);
    if (routedToMainUI) {
        routedToMainUI = false;
        appDidRouteFromMainUI();
    }
}

(:glance, :typecheck(disableBackgroundCheck))
function onAppDidFinishLaunching() as Void {
    _([L_APP, "onAppDidFinishLaunching"]);
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
    _([L_APP, "didSeeIncomingMessageWhileRoutedToMainUI"]);
    var checkIn = getCheckInImp();
    if (checkIn != null) {
        checkIn.remoteResponded();
    }
}

(:glance, :background)
function onBackgroundDataImp(data as Application.PersistableType) as Void {
    _([L_APP_LIFE_CYCLE, "onBackgroundData", data]);
    _([L_APP_STAT, "systemStats", systemStatsDumpRep()]);
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
