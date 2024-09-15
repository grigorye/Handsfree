using Toybox.Application;
using Toybox.Background;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Communications;

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
        Background.registerForPhoneAppMessageEvent();
    }

    (:typecheck(disableGlanceCheck))
    function getServiceDelegate() as [System.ServiceDelegate] {
        _2(L_APP_EXTRA, "getServiceDelegate");
        return [new BackgroundServiceDelegate()];
    }

    function onBackgroundData(data as Application.PersistableType) as Void {
        _3(LX_APP_LIFE_CYCLE, "onBackgroundData", { "data" => data });
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
        _3(LX_APP_LIFE_CYCLE, "checkInSkipped.dueToCallState", callState);
        return;
    }
    if (!AppSettings.isCheckInEnabled) {
        _2(LX_APP_LIFE_CYCLE, "checkInSkipped.dueToSettings");
        return;
    }
    if (checkInImp != null) {
        System.error("checkInImp != null");
    }
    getCheckIn().launch();
}

(:widget)
function appDidRouteFromMainUI() as Void {
    _2(L_APP, "appDidRouteFromMainUI");
    setRoutedCallStateImp(null);
    checkInImp = null;
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
    eraseAppDataIfNecessary();
    (new InAppIncomingMessageDispatcher()).launch();
}

function didSeeIncomingMessageWhileRoutedToMainUI() as Void {
    _2(L_APP, "didSeeIncomingMessageWhileRoutedToMainUI");
    if (checkInImp != null) {
        checkInImp.remoteResponded();
    }
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIFromBackgroundData() as Void {
    WatchUi.requestUpdate();
}
