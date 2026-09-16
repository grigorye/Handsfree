import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Notifications;

(:settings)
module SettingsScreen {

class View extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => Rez.Strings.menuSettings });
        addItem(incomingCallsMenuItem());
        addItem(showPhoneNumbersMenuItem());
        addItem(optimisticCallHandlingMenuItem());
        addItem(broadcastListeningMenuItem());
        addItem(new MenuItem(Rez.Strings.menuAbout, null, :about, null));
    }

    function incomingCallsMenuItem() as WatchUi.ToggleMenuItem {
        return new ToggleMenuItem(
            Rez.Strings.toggleRinging,
            {
                :enabled => incomingCallsEnabledMenuItemTitle(),
                :disabled => Rez.Strings.uiOff
            },
            :openAppOnIncomingCall,
            BackgroundSettings.isOpenAppOnIncomingCallEnabled(),
            null
        );
    }

    function showPhoneNumbersMenuItem() as WatchUi.ToggleMenuItem {
        return new ToggleMenuItem(
            Rez.Strings.togglePhoneNumbers,
            {
                :enabled => Rez.Strings.uiOn,
                :disabled => Rez.Strings.uiOff
            },
            :showPhoneNumbers,
            AppSettings.isShowingPhoneNumbersEnabled(),
            null
        );
    }

    function optimisticCallHandlingMenuItem() as WatchUi.ToggleMenuItem {
        return new ToggleMenuItem(
            Rez.Strings.toggleFasterCalls,
            {
                :enabled => Rez.Strings.uiOn,
                :disabled => Rez.Strings.uiOff
            },
            :optimisticCallHandling,
            AppSettings.isOptimisticCallHandlingEnabled(),
            null
        );
    }

    function broadcastListeningMenuItem() as WatchUi.ToggleMenuItem {
        return new ToggleMenuItem(
            Rez.Strings.toggleEagerSync,
            {
                :enabled => Rez.Strings.uiOn,
                :disabled => Rez.Strings.uiOff
            },
            :broadcastListening,
            isBroadcastListeningEnabled(),
            null
        );
    }

    function update() as Void {
        (getItem(findItemById(:openAppOnIncomingCall)) as WatchUi.ToggleMenuItem).setEnabled(BackgroundSettings.isOpenAppOnIncomingCallEnabled());
        (getItem(findItemById(:showPhoneNumbers)) as WatchUi.ToggleMenuItem).setEnabled(AppSettings.isShowingPhoneNumbersEnabled());
        (getItem(findItemById(:optimisticCallHandling)) as WatchUi.ToggleMenuItem).setEnabled(AppSettings.isOptimisticCallHandlingEnabled());
        (getItem(findItemById(:broadcastListening)) as WatchUi.ToggleMenuItem).setEnabled(isBroadcastListeningEnabled());
        workaroundNoRedrawForMenu2(self);
    }
}

(:noReadiness)
function incomingCallsEnabledMenuItemTitle() as StringOrResource {
    return incomingCallsEnabledMenuItemTitleIgnoringReadiness();
}

(:readiness)
function incomingCallsEnabledMenuItemTitle() as StringOrResource {
    var readiness = ReadinessInfoManip.readiness(ReadinessField_incomingCalls);
    if (!readiness.equals(ReadinessValue_ready)) {
        return Rez.Strings.uiOnNotReady;
    } else {
        return incomingCallsEnabledMenuItemTitleIgnoringReadiness();
    }
}

function incomingCallsEnabledMenuItemTitleIgnoringReadiness() as StringOrResource {
    if (BackgroundSettings.isIncomingOpenAppViaCompanionEnabled) {
        return Rez.Strings.modeVibrationAlert;
    } else if (BackgroundSettings.isOpenAppViaNotificationEnabled()) {
        return Rez.Strings.modeNotification;
    } else {
        return Rez.Strings.modeAlert;
    }
}

}

(:settings)
function newSettingsView() as SettingsScreen.View {
    var settingsView = new SettingsScreen.View();
    settingsView.update();
    return settingsView;
}
