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
    handleRemoteMessageData(data);
}

(:background)
function handleRemoteMessageData(data as Lang.Object) as Void {
    var lowMemoryDebug = minDebug && !isActiveUiKindApp && lowMemory;
    if (minDebug) { 
        if (lowMemoryDebug) {
            _3(LX_REMOTE_MSG, "msg", "<redacted-for-low-memory>");
        } else {
            _3(LX_REMOTE_MSG, "msg", data);
        }
    }
    didReceiveRemoteMessage();
    if (data.equals("ping")) {
        if (minDebug) { _3(LX_REMOTE_MSG, "msg.data", "gotPing"); }
        handlePing();
        return;
    }
    var msg = data as Lang.Dictionary<Lang.String, Lang.Object>;
    var cmd = msg[cmdMsgField] as Lang.String | Null;
    if (cmd == null) {
        if (minDebug) { _3(LX_REMOTE_MSG, "msg", "noCmdMsgField"); }
        return;
    }
    if (lowMemoryDebug) { _3(LX_REMOTE_MSG, "msg.cmd", cmd); }
    var args = msg[argsMsgField] as Lang.Dictionary<Lang.String, Lang.Object>;
    switch (cmd) {
        case InCmd_subjectsChanged:
            handleSubjectsChanged(args[subjectsK] as SubjectsChanged);
            break;
        case InCmd_acceptQueryResult:
            handleAcceptQueryResult(args);
            break;
        case InCmd_openAppFailed:
            openAppFailed();
            break;
        case InCmd_openMeCompleted:
            handleOpenMeCompleted(args);            
            break;
        default:
            if (debug) { _3(LX_REMOTE_MSG, "unknownCmd", cmd); }
            break;
    }
    if (minDebug) { _2(LX_REMOTE_MSG, "msg.committed"); }
}

typedef SubjectName as Lang.String;
typedef SubjectsChanged as Lang.Dictionary<SubjectName, Lang.Dictionary<Lang.String, Lang.Object>>;

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
    if (minDebug) { _3(LX_REMOTE_MSG, "subjectsReceived", names); }
    var subjectsConfirmed = "";
    for (var i = 0; i < namesCount; i++) {
        var name = names[i];
        if (allSubjects.find(name) == null) {
            if (minDebug) { _3(LX_REMOTE_MSG, "unknownSubject", name); }
            continue;
        }
        var subject = subjects[name] as Lang.Dictionary<Lang.String, Lang.Object>;
        var version = subject[versionK] as Version;
        if (name.equals(appConfigSubject)) {
            if (!version.equals(BackgroundSettings.appConfigVersion())) {
                subjectsInvalidated = subjectsInvalidated + name;
                isHit = false;
            } else {
                if (debug) { _3(LX_REMOTE_MSG, "appConfigHit", version); }
                subjectsConfirmed = subjectsConfirmed + name;
            }
            continue;
        }
        switch (name) {
            case audioStateSubject: {
                if (version.equals(Storage.getValue(AudioState_versionKey))) {
                    subjectsConfirmed = subjectsConfirmed + name;
                    continue;
                }
                var audioState = subject[valueK] as AudioState or Null;
                if (audioState != null) {
                    var pendingAudioState = AudioStateImp.pendingAudioStateImp;
                    if (pendingAudioState != null) {
                        var newActiveAudioDevice = pendingAudioState[activeAudioDeviceK] as Lang.String | Null;
                        if (newActiveAudioDevice != null) {
                            var oldActiveAudioDevice = audioState[activeAudioDeviceK] as Lang.String | Null;
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
                break;
            }
        }
        // Store versions and values.
        var versionKey = versionKeyForSubject(name);
        var oldVersion = Storage.getValue(versionKey) as Version | Null;
        if (!version.equals(oldVersion)) {
            var value = subject[valueK];
            if (value == null) {
                subjectsInvalidated = subjectsInvalidated + name;
            } else {
                var valueKey = valueKeyForSubject(name);
                storeVersion(versionKey, version);
                storeValue(valueKey, value);
                subjectsConfirmed = subjectsConfirmed + name;
            }
            isHit = false;
        } else {
            if (debug) { _3(LX_REMOTE_MSG, "Hit." + versionKey, version); }
            subjectsConfirmed = subjectsConfirmed + name;
        }
    }
    if (minDebug) { _3(LX_REMOTE_MSG, "invalidation", { "pending" => subjectsInvalidated, "isHit" => isHit }); }
    trackHits(isHit);
    trackSubjectsConfirmed(subjectsConfirmed);
    return subjectsInvalidated;
}

(:background, :lowMemory)
function didReceiveRemoteMessage() as Void {
}

(:background, :typecheck(disableBackgroundCheck), :noLowMemory)
function didReceiveRemoteMessage() as Void {
    trackValidRemoteMessageReceived();
    if (isActiveUiKindApp) {
        didReceiveRemoteMessageInForeground();
    }
}

(:noLowMemory)
function didReceiveRemoteMessageInForeground() as Void {
    if (debug) { beep(BEEP_TYPE_MESSAGE); }
}

(:background, :glance)
function versionKeyForSubject(subject as Lang.String) as Lang.String {
    return subject + versionKeySuffix;
}

(:background, :glance)
function valueKeyForSubject(subject as Lang.String) as Lang.String {
    return subject + valueKeySuffix;
}

}