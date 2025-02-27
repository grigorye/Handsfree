import Toybox.WatchUi;
import Toybox.Lang;

const L_USER_ACTION as LogComponent = "userAction";
const L_USER_ACTION_DEBUG as LogComponent = "userAction";

class CallInProgressViewDelegate extends WatchUi.Menu2InputDelegate {
    var phone as Phone;

    function initialize(phone as Phone) {
        self.phone = phone;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        if (debug) { _3(L_USER_ACTION, "callInProgress.onSelect", { "phone" => phone, "item" => item.getId() }); }
        var action = item.getId() as CallInProgressAction;
        if (debug) { _2(L_USER_ACTION_DEBUG, action); }
        switch (action) {
            case CALL_IN_PROGRESS_ACTION_ACCEPT: {
                Req.acceptIncomingCall(phone);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_HANGUP: {
                Req.hangupCallInProgress(phone);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_REJECT: {
                Req.rejectIncomingCall(phone);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_IGNORE: {
                Req.ignoreIncomingCall(phone);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_MUTE: {
                var isMuted = AudioStateImp.getIsMuted(AudioStateImp.getPendingAudioState());
                Req.sendMute(!isMuted);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_AUDIO_VOLUME: {
                selectAudioVolume();
                break;
            }
        }
    }

    function onBack() {
        if (debug) { _2(L_USER_ACTION, "callInProgress.onBack"); }
        exitToSystemFromCurrentView();
    }
}
