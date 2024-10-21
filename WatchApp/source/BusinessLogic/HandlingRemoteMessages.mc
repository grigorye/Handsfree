import Toybox.Lang;
import Toybox.Communications;
import Toybox.System;
import Toybox.Application;

(:background)
const LX_REMOTE_MSG as LogComponent = "<";

(:background)
function handleRemoteMessage(iqMsg as Communications.Message or Null) as Void {
    trackRawRemoteMessageReceived();
    if (iqMsg == null) {
        if (minDebug) { _3(LX_REMOTE_MSG, "msg", "isNull!"); }
        return;
    }
    if (!(iqMsg instanceof Communications.Message)) {
        if (debug) { _3(LX_REMOTE_MSG, "msg", "isNotMessage!"); }
        if (debug) { _3(LX_REMOTE_MSG, "msg", iqMsg); }
        return;
    }
    var data = iqMsg.data;
    if (!(data instanceof Lang.Object)) {
        if (minDebug) { _3(LX_REMOTE_MSG, "msg", "dataIsNotObject: " + data); }
        return;
    }
    var lowMemoryDebug = minDebug && !isActiveUiKindApp && lowMemory;
    if (minDebug) { 
        if (lowMemoryDebug) {
            _3(LX_REMOTE_MSG, "msg", "<redacted-for-low-memory>");
        } else {
            _3(LX_REMOTE_MSG, "msg", iqMsg.data);
        }
    }
    didReceiveRemoteMessage();
    if (data.equals("ping")) {
        if (minDebug) { _3(LX_REMOTE_MSG, "msg.data", "gotPing"); }
        return;
    }
    var msg = iqMsg.data as Lang.Dictionary<Lang.String, Lang.Object>;
    var cmd = msg["cmd"] as Lang.String;
    if (lowMemoryDebug) {
        _3(LX_REMOTE_MSG, "msg.cmd", cmd);
    }
    var args = msg["args"] as Lang.Dictionary<Lang.String, Lang.Object>;
    switch (cmd) {
        case "syncYou":
            var phonesArgs = args["setPhones"] as Lang.Dictionary<Lang.String, Lang.Object>;
            setPhones(phonesArgs["phones"] as Phones);
            if (!callStateIsOwnedByUs) {
                var phoneStateChangedArgs = args["phoneStateChanged"] as Lang.Dictionary<Lang.String, Lang.Object> or Null;
                if (phoneStateChangedArgs != null) {
                    handlePhoneStateChanged(phoneStateChangedArgs);
                }
                callStateIsOwnedByUs = true;
            } else {
                if (debug) { _3(LX_REMOTE_MSG, "callStateIsNotOwnedByUs", true); }
            }
            break;
        case "setPhones":
            setPhones(args["phones"] as Phones);
            break;
        case "subjectsChanged":
            handleSubjectsChanged(args["subjects"] as SubjectsChanged);
            break;
        case "acceptQueryResult":
            handleAcceptQueryResult(args);
            break;
        case "phoneStateChanged":
            handlePhoneStateChanged(args);
            break;
        case "openAppFailed":
            openAppFailed();
            break;
        case "openMeCompleted":
            handleOpenMeCompleted(args);            
            break;
    }
    if (minDebug) {
        _2(LX_REMOTE_MSG, "msg.committed");
    }
}

(:background)
const L_PHONE_STATE_CHANGED as LogComponent = "phoneStateChanged";

typedef Version as Lang.String;

typedef SubjectsChanged as Lang.Dictionary<Lang.String, Lang.Dictionary<Lang.String, Lang.Object>>;

(:background)
function handleAcceptQueryResult(args as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    var subjects = args["subjects"] as SubjectsChanged;
    var subjectsInvalidated = handleSubjectsChanged(subjects);
    if (subjectsInvalidated.size() > 0) {
        requestSubjects(subjectsInvalidated);
    }
}

(:background)
function handleSubjectsChanged(subjects as SubjectsChanged) as Lang.Array<Lang.String> {
    var subjectsInvalidated = [];
    var names = subjects.keys() as Lang.Array<Lang.String>;
    var namesCount = names.size();
    var isHit = true;
    if (minDebug) {
        _3(LX_REMOTE_MSG, "subjectsReceived", names);
    }
    for (var i = 0; i < namesCount; i++) {
        var name = names[i];
        var subject = subjects[name] as Lang.Dictionary<Lang.String, Lang.Object>;
        var version = subject["version"] as Version;
        switch (name) {
            case "phones": {
                if (!version.equals(getPhonesVersion())) {
                    var phones = subject["value"] as Phones or Null;
                    if (phones == null) {
                        subjectsInvalidated.add(name);
                    } else {
                        setPhones(phones);
                        setPhonesVersion(version);
                    }
                    isHit = false;
                } else {
                    if (debug) { _3(LX_REMOTE_MSG, "phonesHit", version); }
                }
                break;
            }
            case "recents": {
                if (!version.equals(getRecentsVersion())) {
                    var recents = subject["value"] as Recents or Null;
                    if (recents == null) {
                        subjectsInvalidated.add(name);
                    } else {
                        setRecents(recents);
                        setRecentsVersion(version);
                    }
                    isHit = false;
                } else {
                    if (debug) { _3(LX_REMOTE_MSG, "recentsHit", version); }
                }
                break;
            }
            case "audioState": {
                if (!version.equals(AudioStateManip.getAudioStateVersion())) {
                    var audioState = subject["value"] as AudioState or Null;
                    if (audioState == null) {
                        subjectsInvalidated.add(name);
                    } else {
                        if (AudioStateImp.pendingAudioStateImp == null) {
                            AudioStateImp.pendingAudioStateImp = audioState;
                        }
                        AudioStateManip.setAudioState(audioState);
                        AudioStateManip.setAudioStateVersion(version);
                    }
                    isHit = false;
                } else {
                    if (debug) { _3(LX_REMOTE_MSG, "audioStateHit", version); }
                }
                break;
            }
            default: {
                if (debug) { _3(LX_REMOTE_MSG, "unknownSubject", name); }
                break;
            }
        }
    }
    if (minDebug) {
        _3(LX_REMOTE_MSG, "invalidation", { "pending" => subjectsInvalidated, "isHit" => isHit });
    }
    trackHits(isHit);
    return subjectsInvalidated;
}

(:background)
function handlePhoneStateChanged(args as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    var callState = getCallState();
    if (debug) { _3(L_PHONE_STATE_CHANGED, "oldCallState", callState); }
    var phoneState = args["state"] as Lang.String;
    if (debug) { _3(L_PHONE_STATE_CHANGED, "inPhoneState", phoneState); }
    if (!phoneState.equals("ringing")) {
        stopRequestingAttentionIfInApp();
    }
    var optimisticCallState = nextOptimisticCallState();
    switch (phoneState) {
        case "callInProgress":
            var inProgressNumber = args["number"] as Lang.String or Null;
            var inProgressName = args["name"] as Lang.String or Null;
            if (debug) { _3(L_PHONE_STATE_CHANGED, "inProgressNumber", inProgressNumber); }
            if (optimisticCallState != null) {
                if (optimisticCallState instanceof CallInProgress) {
                    var phoneNumber = getPhoneNumber(optimisticCallState.phone);
                    if (((phoneNumber != null) && phoneNumber.equals(inProgressNumber)) || (inProgressNumber == null /* no permission in companion */)) {
                        if (debug) { _3(L_PHONE_STATE_CHANGED, "optimisticCallStateHit", optimisticCallState); }
                        var isCurrent = objectsEqual(getCallState(), optimisticCallState);
                        untrackOptimisticCallState(optimisticCallState);
                        if (isCurrent) {
                            setCallState(optimisticCallState);
                            updateUIForCallState();
                        }
                        return;
                    }
                }
                if (debug) { _3(L_PHONE_STATE_CHANGED, "resetOptimisticCallStatesDueTo", optimisticCallState); }
                resetOptimisticCallStates();
            }
            var inProgressPhone = {
                "number" => inProgressNumber,
                "id" => -3
            } as Phone;
            if (inProgressName != null) {
                setPhoneName(inProgressPhone, inProgressName as Lang.String);
            }
            if (callState instanceof DismissedCallInProgress) {
                var dismissedNumber = callState.phone["number"] as Lang.String;
                var dismissedButChanged = !dismissedNumber.equals(inProgressNumber);
                if (debug) { _3(L_PHONE_STATE_CHANGED, "dismissedButChanged", dismissedButChanged); }
                if (dismissedButChanged) {
                    setCallState(new CallInProgress(inProgressPhone));
                }
            } else {
                setCallState(new CallInProgress(inProgressPhone));
            }
            break;
        case "noCallInProgress":
            if (optimisticCallState != null) {
                if (optimisticCallState instanceof Idle) {
                    if (debug) { _3(L_PHONE_STATE_CHANGED, "optimisticCallStateHit", optimisticCallState); }
                    untrackOptimisticCallState(optimisticCallState);
                    updateUIForCallState();
                    return;
                }
                if (debug) { _3(L_PHONE_STATE_CHANGED, "resetOptimisticCallStatesDueTo", optimisticCallState); }
                resetOptimisticCallStates();
            }
            setCallState(new Idle());
            break;
        case "ringing":
            var ringingNumber = args["number"] as Lang.String;
            if (debug) { _3(L_PHONE_STATE_CHANGED, "inRingingNumber", ringingNumber); }
            var ringingPhone = {
                "number" => ringingNumber,
                "id" => -4,
                "ringing" => true
            } as Phone;
            var ringingName = args["name"] as Lang.String or Null;
            if (ringingName != null) {
                setPhoneName(ringingPhone, ringingName as Lang.String);
            }
            resetOptimisticCallStates();
            setCallState(new CallInProgress(ringingPhone));
            openAppOnIncomingCallIfNecessary(ringingPhone);
            break;
    }
}

(:background, :typecheck(disableBackgroundCheck))
function didReceiveRemoteMessage() as Void {
    trackValidRemoteMessageReceived();
    if (isActiveUiKindApp) {
        didReceiveRemoteMessageInForeground();
    }
}

function didReceiveRemoteMessageInForeground() as Void {
    beep(BEEP_TYPE_MESSAGE);
}
