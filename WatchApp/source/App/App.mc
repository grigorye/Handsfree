using Toybox.Application;
using Toybox.Background;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Communications;

(:glance, :background)
class App extends Application.AppBase {

    var backgroundServiceEnabled as Lang.Boolean;
    
    function initialize() {
        dump("initialize", true);
        dump("deviceSettings", deviceSettingsDumpRep(System.getDeviceSettings()));
        dump("systemStats", systemStatsDumpRep());
        dump("backgroundAppUpdateEnabled", isBackgroundAppUpdateEnabled());
        dump("appType", appType());
        dump("everSeenCompanion", everSeenCompanion());
        Application.AppBase.initialize();
        backgroundServiceEnabled = isBackgroundServiceEnabled();
        dump("backgroundServiceEnabled", backgroundServiceEnabled);
        dump("getPhoneAppMessageEventRegistered", Background.getPhoneAppMessageEventRegistered());
        if (backgroundServiceEnabled) {
            Background.registerForPhoneAppMessageEvent();
        } else {
            Background.deletePhoneAppMessageEvent();
        }
    }

    function onStart(state) {
        dump("onStart", state);
        Application.AppBase.onStart(state);
    }

    function onStop(state) {
        dump("activeUiKindOnStop", getActiveUiKind());
        dump("onStop", state);
        dump("systemStats", systemStatsDumpRep());
        Application.AppBase.onStop(state);
    }

    (:background, :typecheck(disableGlanceCheck))
    function getServiceDelegate() as [System.ServiceDelegate] {
        dump("getServiceDelegate", true);
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
        dump("getInitialView", true);
        eraseAppDataIfNecessary();
        var inWidgetMode = isInWidgetMode();
        dump("inWidgetMode", inWidgetMode);
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
        dump("getGlanceView", true);
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
    dump("appWillRouteToMainUI", true);
}

var routedToMainUI as Lang.Boolean = false;

function appDidRouteToMainUI() as Void {
    if (routedToMainUI) {
        System.error("Already routed to main UI");
    }
    routedToMainUI = true;
    if (getCheckInImp() != null) {
        System.error("getCheckInImp() != null");
    }
    getCheckIn().launch();
}

(:widget)
function appDidRouteFromMainUI() as Void {
    dump("appDidRouteFromMainUI", true);
    setRoutedCallStateImp(null);
    setPhonesViewImp(null);
    if (getCheckInImp() == null) {
        System.error("getCheckInImp() == null");
    }
    getCheckIn().cancel();
    setCheckInImp(null);
}


(:widget)
function widgetDidShow() as Void {
    dump("widgetDidShow", true);
    if (routedToMainUI) {
        routedToMainUI = false;
        appDidRouteFromMainUI();
    }
}

(:glance, :typecheck(disableBackgroundCheck))
function onAppDidFinishLaunching() as Void {
    dump("onAppDidFinishLaunching", true);
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
    dump("didSeeIncomingMessageWhileRoutedToMainUI", true);
    var checkIn = getCheckInImp();
    if (checkIn != null) {
        checkIn.remoteResponded();
    }
}

(:glance, :background)
function onBackgroundDataImp(data as Application.PersistableType) as Void {
    dump("onBackgroundData", data);
    dump("systemStats", systemStatsDumpRep());
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
