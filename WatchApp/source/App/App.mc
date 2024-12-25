import Toybox.Application;
import Toybox.Background;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Communications;

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
        trackFirstLaunch();
        if (minDebug) { _2(L_APP_EXTRA, "getServiceDelegate"); }
        return [new BackgroundServiceDelegate()];
    }

    function onBackgroundData(data as Application.PersistableType) as Void {
        if (minDebug) { _3(LX_APP_LIFE_CYCLE, "onBackgroundData", { "data" => data }); }
        updateUIFromBackgroundData();
        AppBase.onBackgroundData(data);
    }

    (:typecheck([disableGlanceCheck, disableBackgroundCheck]))
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return getInitialViewInApp();
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

function willReturnInitialView() as Void {
    setActiveUiKind(ACTIVE_UI_APP);
    onAppDidFinishLaunching();
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
    VT.trackInitialView(V.comm, view, null);
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
    syncIfNecessary();
}

function syncIfNecessary() as Void {
    if (BackgroundSettings.isBroadcastListeningEnabled()) {
        if (debug) { _2(LX_APP_LIFE_CYCLE, "syncSkipped.inFavorOfBroadcasts"); }
        return;
    }
    var callState = getCallState();
    if (!(callState instanceof Idle)) {
        if (debug) { _3(LX_APP_LIFE_CYCLE, "syncSkipped.dueToCallState", callState); }
        return;
    }
    requestAllSubjects();
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
    eraseAppDataIfNecessary();
    (new InAppIncomingMessageDispatcher()).launch();
}

function didSeeIncomingMessageWhileRoutedToMainUI() as Void {
    if (debug) { _2(L_APP, "didSeeIncomingMessageWhileRoutedToMainUI"); }
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIFromBackgroundData() as Void {
    WatchUi.requestUpdate();
}
