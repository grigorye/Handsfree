import Toybox.Lang;
import Toybox.Communications;
import Toybox.System;
import Toybox.Application;

(:background)
const LX_REMOTE_MSG as LogComponent = "<";

(:background)
function handleRemoteMessage(iqMsgObject as Lang.Object or Null) as Void {
    trackRawRemoteMessageReceived();
    if (iqMsgObject == null) {
        if (minDebug) { _3(LX_REMOTE_MSG, "msg", "isNull!"); }
        return;
    }
    if (!(iqMsgObject instanceof Communications.Message)) {
        if (debug) { _3(LX_REMOTE_MSG, "msg", "isNotMessage!"); }
        if (debug) { _3(LX_REMOTE_MSG, "msg", iqMsgObject); }
        return;
    }
    var iqMsg = iqMsgObject as Communications.Message;
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
        handlePing();
        return;
    }
    var msg = iqMsg.data as Lang.Dictionary<Lang.String, Lang.Object>;
    var cmd = msg[cmdMsgField] as Lang.String;
    if (lowMemoryDebug) {
        _3(LX_REMOTE_MSG, "msg.cmd", cmd);
    }
    var args = msg[argsMsgField] as Lang.Dictionary<Lang.String, Lang.Object>;
    switch (cmd) {
        case InCmd.subjectsChanged:
            handleSubjectsChanged(args[subjectsK] as SubjectsChanged);
            break;
        case InCmd.acceptQueryResult:
            handleAcceptQueryResult(args);
            break;
        case InCmd.phoneStateChanged:
            handlePhoneStateChanged(args);
            break;
        case InCmd.openAppFailed:
            openAppFailed();
            break;
        case InCmd.openMeCompleted:
            handleOpenMeCompleted(args);            
            break;
        default:
            _3(LX_REMOTE_MSG, "unknownCmd", cmd);
            break;
    }
    if (minDebug) {
        _2(LX_REMOTE_MSG, "msg.committed");
    }
}

(:background)
const L_PHONE_STATE_CHANGED as LogComponent = "phoneStateChanged";

typedef Version as Lang.Number;

typedef SubjectsChanged as Lang.Dictionary<Lang.String, Lang.Dictionary<Lang.String, Lang.Object>>;

(:background)
function handleAcceptQueryResult(args as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    var subjects = args[subjectsK] as SubjectsChanged;
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
        var version = subject[versionK] as Version;
        switch (name) {
            case phonesSubject: {
                if (!version.equals(PhonesManip.getPhonesVersion())) {
                    var phones = subject[valueK] as Phones or Null;
                    if (phones == null) {
                        subjectsInvalidated.add(name);
                    } else {
                        PhonesManip.setPhones(phones);
                        PhonesManip.setPhonesVersion(version);
                    }
                    isHit = false;
                } else {
                    if (debug) { _3(LX_REMOTE_MSG, "phonesHit", version); }
                }
                break;
            }
            case recentsSubject: {
                if (!version.equals(RecentsManip.getRecentsVersion())) {
                    var recents = subject[valueK] as Recents or Null;
                    if (recents == null) {
                        subjectsInvalidated.add(name);
                    } else {
                        RecentsManip.setRecents(recents);
                        RecentsManip.setRecentsVersion(version);
                    }
                    isHit = false;
                } else {
                    if (debug) { _3(LX_REMOTE_MSG, "recentsHit", version); }
                }
                break;
            }
            case audioStateSubject: {
                if (!version.equals(AudioStateManip.getAudioStateVersion())) {
                    var audioState = subject[valueK] as AudioState or Null;
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
            case companionInfoSubject: {
                if (!version.equals(CompanionInfoManip.getCompanionInfoVersion())) {
                    var companionInfo = subject[valueK] as CompanionInfo or Null;
                    if (companionInfo == null) {
                        subjectsInvalidated.add(name);
                    } else {
                        CompanionInfoManip.setCompanionInfo(companionInfo);
                        CompanionInfoManip.setCompanionInfoVersion(version);
                    }
                    isHit = false;
                } else {
                    if (debug) { _3(LX_REMOTE_MSG, "companionInfoHit", version); }
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
function handlePhoneStateChanged(state as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    var callState = getCallState();
    if (debug) { _3(L_PHONE_STATE_CHANGED, "oldCallState", callState); }
    var stateId = state[PhoneState.stateId] as Lang.String;
    if (debug) { _3(L_PHONE_STATE_CHANGED, "inPhoneState", stateId); }
    if (!stateId.equals(PhoneStateId.ringing)) {
        stopRequestingAttentionIfInApp();
    }
    var optimisticCallState = nextOptimisticCallState();
    switch (stateId) {
        case PhoneStateId.offHook:
            var inProgressNumber = state[PhoneState.number] as Lang.String or Null;
            var inProgressName = state[PhoneState.name] as Lang.String or Null;
            if (debug) { _3(L_PHONE_STATE_CHANGED, "inProgressNumber", inProgressNumber); }
            if (optimisticCallState != null) {
                if (optimisticCallState instanceof CallInProgress) {
                    var phoneNumber = getPhoneNumber(optimisticCallState.phone);
                    if (((phoneNumber != null) && phoneNumber.equals(inProgressNumber)) || (inProgressNumber == null /* no permission in companion */)) {
                        if (debug) { _3(L_PHONE_STATE_CHANGED, "optimisticCallStateHit", optimisticCallState); }
                        var isCurrent = objectsEqual(callState, optimisticCallState);
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
                PhoneField.number => inProgressNumber,
                PhoneField.id => -3
            } as Phone;
            if (inProgressName != null) {
                setPhoneName(inProgressPhone, inProgressName as Lang.String);
            }
            if (callState instanceof DismissedCallInProgress) {
                var dismissedNumber = callState.phone[PhoneField.number] as Lang.String;
                var dismissedButChanged = !dismissedNumber.equals(inProgressNumber);
                if (debug) { _3(L_PHONE_STATE_CHANGED, "dismissedButChanged", dismissedButChanged); }
                if (dismissedButChanged) {
                    setCallState(new CallInProgress(inProgressPhone));
                }
            } else {
                setCallState(new CallInProgress(inProgressPhone));
            }
            break;
        case PhoneStateId.idle:
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
        case PhoneStateId.ringing:
            var ringingNumber = state[PhoneState.number] as Lang.String;
            if (debug) { _3(L_PHONE_STATE_CHANGED, "inRingingNumber", ringingNumber); }
            var ringingPhone = {
                PhoneField.number => ringingNumber,
                PhoneField.id => -4,
                PhoneField.ringing => true
            } as Phone;
            var ringingName = state[PhoneState.name] as Lang.String or Null;
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
