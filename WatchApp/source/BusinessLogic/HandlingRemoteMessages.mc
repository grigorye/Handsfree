import Toybox.Lang;
import Toybox.Communications;
import Toybox.System;
import Toybox.Application;

(:background)
const LX_REMOTE_MSG as LogComponent = "<";

typedef Version as Lang.Number;

module Req {

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
        case InCmd_subjectsChanged:
            handleSubjectsChanged(args[subjectsK] as SubjectsChanged);
            break;
        case InCmd_acceptQueryResult:
            handleAcceptQueryResult(args);
            break;
        case InCmd_phoneStateChanged:
            handlePhoneStateChanged(args);
            break;
        case InCmd_openAppFailed:
            openAppFailed();
            break;
        case InCmd_openMeCompleted:
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

typedef SubjectsChanged as Lang.Dictionary<Lang.String, Lang.Dictionary<Lang.String, Lang.Object>>;

(:background)
function handleAcceptQueryResult(args as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    var subjects = args[subjectsK] as SubjectsChanged;
    var subjectsInvalidated = handleSubjectsChanged(subjects);
    if (!subjectsInvalidated.equals("")) {
        requestSubjects(subjectsInvalidated);
    }
}

(:background)
function handleSubjectsChanged(subjects as SubjectsChanged) as Lang.String {
    var subjectsInvalidated = "";
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
            case broadcastSubject: {
                if (!version.equals(BackgroundSettings.broadcastListeningVersion())) {
                    subjectsInvalidated = subjectsInvalidated + name;
                    isHit = false;
                } else {
                    if (debug) { _3(LX_REMOTE_MSG, "broadcastHit", version); }
                }
                break;
            }
            case audioStateSubject: {
                if (version.equals(Storage.getValue(AudioState_versionKey))) {
                    break;
                }
                var audioState = subject[valueK] as AudioState or Null;
                if (audioState != null) {
                    var pendingAudioState = AudioStateImp.pendingAudioStateImp;
                    if (pendingAudioState != null) {
                        var newActiveAudioDevice = pendingAudioState[activeAudioDeviceK] as Lang.String | Null;
                        if (newActiveAudioDevice != null) {
                            var oldActiveAudioDevice = audioState[activeAudioDeviceK];
                            if ((oldActiveAudioDevice == null) || !oldActiveAudioDevice.equals(newActiveAudioDevice)) {
                                var isMuted = pendingAudioState[isMutedK] as Lang.Boolean;
                                pendingAudioState = AudioStateImp.clone(audioState);
                                pendingAudioState[isMutedK] = isMuted;
                                AudioStateImp.pendingAudioStateImp = pendingAudioState;
                            }
                        }
                    } else {
                        AudioStateImp.pendingAudioStateImp = audioState;
                    }
                }
                // fall through
            }
            case recentsSubject:
            case phonesSubject:
            case readinessInfoSubject:
            case companionInfoSubject: {
                var versionKey = versionKeyForSubject(name);
                if (versionKey == null) {
                    System.error("");
                }
                var oldVersion = Storage.getValue(versionKey) as Version | Null;
                if (!version.equals(oldVersion)) {
                    var value = subject[valueK];
                    if (value == null) {
                        subjectsInvalidated = subjectsInvalidated + name;
                    } else {
                        var valueKey = valueKeyForSubject(name) as Lang.String;
                        storeValue(valueKey, value);
                        Storage.setValue(versionKey, version);
                    }
                    isHit = false;
                } else {
                    if (debug) { _3(LX_REMOTE_MSG, "Hit." + versionKey, version); }
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
    var stateId = state[PhoneState_stateId] as Lang.String;
    if (debug) { _3(L_PHONE_STATE_CHANGED, "inPhoneState", stateId); }
    if (!stateId.equals(PhoneStateId_ringing)) {
        stopRequestingAttentionIfInApp();
    }
    var optimisticCallState = nextOptimisticCallState();
    switch (stateId) {
        case PhoneStateId_offHook:
            var inProgressNumber = state[PhoneState_number] as Lang.String or Null;
            var inProgressName = state[PhoneState_name] as Lang.String or Null;
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
                PhoneField_number => inProgressNumber,
                PhoneField_id => -3
            } as Phone;
            if (inProgressName != null) {
                setPhoneName(inProgressPhone, inProgressName as Lang.String);
            }
            if (callState instanceof DismissedCallInProgress) {
                var dismissedNumber = callState.phone[PhoneField_number] as Lang.String;
                var dismissedButChanged = !dismissedNumber.equals(inProgressNumber);
                if (debug) { _3(L_PHONE_STATE_CHANGED, "dismissedButChanged", dismissedButChanged); }
                if (dismissedButChanged) {
                    setCallState(new CallInProgress(inProgressPhone));
                }
            } else {
                setCallState(new CallInProgress(inProgressPhone));
            }
            break;
        case PhoneStateId_idle:
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
        case PhoneStateId_ringing:
            var ringingNumber = state[PhoneState_number] as Lang.String;
            if (debug) { _3(L_PHONE_STATE_CHANGED, "inRingingNumber", ringingNumber); }
            var ringingPhone = {
                PhoneField_number => ringingNumber,
                PhoneField_id => -4,
                PhoneField_ringing => true
            } as Phone;
            var ringingName = state[PhoneState_name] as Lang.String or Null;
            if (ringingName != null) {
                setPhoneName(ringingPhone, ringingName as Lang.String);
            }
            resetOptimisticCallStates();
            setCallState(new CallInProgress(ringingPhone));
            openAppOnIncomingCallIfNecessary(ringingPhone);
            break;
    }
}

(:background, :lowMemory)
function trackValidRemoteMessageReceived() as Void {
}

(:background, :typecheck(disableBackgroundCheck))
function didReceiveRemoteMessage() as Void {
    trackValidRemoteMessageReceived();
    if (isActiveUiKindApp) {
        didReceiveRemoteMessageInForeground();
    }
}

function didReceiveRemoteMessageInForeground() as Void {
    if (debug) { beep(BEEP_TYPE_MESSAGE); }
}

(:background)
const versionKeyForSubjectMap = {
    phonesSubject => Phones_versionKey,
    recentsSubject => Recents_versionKey,
    readinessInfoSubject => ReadinessInfo_versionKey,
    companionInfoSubject => CompanionInfo_versionKey,
    audioStateSubject => AudioState_versionKey
} as Lang.Dictionary<Lang.String, Lang.String>;

(:background)
function versionKeyForSubject(subject as Lang.String) as Lang.String | Null {
    return versionKeyForSubjectMap[subject];
}

(:background)
const valueKeyForSubjectMap = {
    phonesSubject => Phones_valueKey,
    recentsSubject => Recents_valueKey,
    readinessInfoSubject => ReadinessInfo_valueKey,
    companionInfoSubject => CompanionInfo_valueKey,
    audioStateSubject => AudioState_valueKey
} as Lang.Dictionary<Lang.String, Lang.String>;

(:background)
function valueKeyForSubject(subject as Lang.String) as Lang.String | Null {
    return valueKeyForSubjectMap[subject];
}

}