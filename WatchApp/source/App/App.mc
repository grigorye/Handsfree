import Toybox.Application;
import Toybox.Background;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Communications;
import Toybox.Notifications;

(:glance, :background)
const L_APP as LogComponent = "app";
(:glance, :background)
const LX_APP_LIFE_CYCLE as LogComponent = "app";
(:glance)
const L_APP_INITIAL_VIEW as LogComponent = "app";
(:glance, :background)
const L_APP_STAT as LogComponent = "app";
(:glance, :background)
const L_APP_EXTRA as LogComponent = "app";

(:glance, :background)
class App extends Application.AppBase {

    function initialize() {
        _preamble();
        AppBase.initialize();
        if (Background has :registerForPhoneAppMessageEvent) {
            Background.registerForPhoneAppMessageEvent();
        }
    }

    (:typecheck(disableGlanceCheck))
    function getServiceDelegate() as [System.ServiceDelegate] {
        if (minDebug) { _2(L_APP_EXTRA, "getServiceDelegate"); }
        return [new Req.BackgroundServiceDelegate()];
    }

    function onBackgroundData(data as Application.PersistableType) as Void {
        dumpF(L_APP, "onBackgroundData");
        if (minDebug) { _3(LX_APP_LIFE_CYCLE, "onBackgroundData", data); }
        updateUIFromBackgroundData();
        AppBase.onBackgroundData(data);
    }

    (:typecheck([disableGlanceCheck, disableBackgroundCheck]))
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return getInitialViewInApp();
    }

    (:typecheck([disableGlanceCheck]))
    function onAppInstall() as Void {
        _2(L_APP, "onAppInstall");
        AppBase.onAppInstall();
        if (isBroadcastListeningEnabled()) {        
            Req.requestSubjects(Req.allSubjects);
        } else {
            TemporalBroadcasting.startTemporalSubjectsBroadcasting();
            TemporalBroadcasting.scheduleStopTemporalSubjectsBroadcasting();
        }
    }

    (:noLowMemory)
    function onAppUpdate() as Void {
        _2(L_APP, "onAppUpdate");
    }
    
    (:noLowMemory)
    function onStart(state as Lang.Dictionary or Null) as Void {
        if (debug) { _3(L_APP, "onStart.state", appStateRep(state)); }
    }

    function onStop(state as Lang.Dictionary or Null) as Void {
        if (debug) { _3(L_APP, "onStop.state", state); }
        if (debug) { _3(L_APP, "activeUiKindOnStop", activeUiKind); }
        if (!activeUiKind.equals(ACTIVE_UI_NONE)) {
            TemporalBroadcasting.scheduleStopTemporalSubjectsBroadcasting();
        }
    }

    function onSettingsChanged() as Void {
        _2(L_APP, "onSettingsChanged");
        appConfigDidChange();
    }

    (:watchAppBuild, :typecheck([disableBackgroundCheck, disableGlanceCheck]), :noLowMemory)
    function onNotification(message as Notifications.NotificationMessage) as Void {
        _3(L_APP, "onNotification", [message.type, message.action]);
        if (message.type == Notifications.NOTIFICATION_MESSAGE_TYPE_DISMISSED) {
            dismissedNotification = true;
        }
    }

    (:typecheck([disableBackgroundCheck]), :watchApp)
    function getGlanceView() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
        setActiveUiKind(ACTIVE_UI_GLANCE);
        return [new GlanceView()];
    }

    (:typecheck([disableBackgroundCheck]), :widget)
    function getGlanceView() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
        System.error("getGlanceView() should not be called for widget");
    }
}

var dismissedNotification as Lang.Boolean = false;

function willReturnInitialView() as Void {
    setActiveUiKind(ACTIVE_UI_APP);
    onAppDidFinishLaunching();
}

(:glance, :typecheck(disableGlanceCheck))
function activeUIKindDidChange() as Void {
    var callState = getCallState();
    if (callState instanceof CallInProgress && isIncomingCallPhone(callState.phone)) {
        if (debug) { _2(L_APP, "notStartingBroadcastsOnRinging"); }
    } else {
        TemporalBroadcasting.startTemporalSubjectsBroadcasting();
    }
    if (isActiveUiKindApp) {
        registerForNotifications();
    }
}

(:widgetBuild)
function registerForNotifications() as Void {
}

(:watchAppBuild, :lowMemory)
function registerForNotifications() as Void {
}

(:watchAppBuild, :noLowMemory)
function registerForNotifications() as Void {
    if (Notifications has :registerForNotificationMessages) {
        Notifications.registerForNotificationMessages(Application.getApp().method(:onNotification));
    }
}

(:widget)
function getInitialViewInApp() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
    willReturnInitialView();
    var view = new WidgetView();
    var delegate = new WidgetViewDelegate();
    VT.trackInitialView("widget", view, delegate);
    return [view, delegate];
}

(:watchApp)
function getInitialViewInApp() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
    willReturnInitialView();
    var view = new CommView();
    VT.trackInitialView(V_comm, view, null);
    return [view];
}

function appWillRouteToMainUI() as Void {
    if (debug) { _2(L_APP, "appWillRouteToMainUI"); }
}

var routedToMainUI as Lang.Boolean = false;

function appDidRouteToMainUI() as Void {
    if (routedToMainUI) {
        System.error("Already routed to main UI");
    }
    routedToMainUI = true;
}

(:widget)
function appDidRouteFromMainUI() as Void {
    if (debug) { _2(L_APP, "appDidRouteFromMainUI"); }
    setRoutedCallStateImp(null);
}

(:widget)
function widgetDidShow() as Void {
    if (debug) { _2(L_APP, "widgetDidShow"); }
    if (routedToMainUI) {
        routedToMainUI = false;
        appDidRouteFromMainUI();
    }
}

function onAppDidFinishLaunching() as Void {
    if (debug) { _2(L_APP, "onAppDidFinishLaunching"); }
    (new Req.InAppIncomingMessageDispatcher()).launch();
}

function didSeeIncomingMessageWhileRoutedToMainUI() as Void {
    if (debug) { _2(L_APP, "didSeeIncomingMessageWhileRoutedToMainUI"); }
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIFromBackgroundData() as Void {
    updateMissedRecents();
    WatchUi.requestUpdate();
}
