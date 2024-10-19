import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;

function openAppInConnectIQ() as Void {
    var msg = {
        "cmd" => "openAppInStore",
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("openAppInStore");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}

function toggleSpeaker() as Void {
    var msg = {
        "cmd" => "toggleSpeaker",
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("toggleSpeaker");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}

function sendMute(on as Lang.Boolean) as Void {
    var audioState = AudioStateImp.clone(AudioStateImp.getPendingAudioState());
    audioState["isMuted"] = on;
    AudioStateManip.setPendingAudioState(audioState);
    var msg = {
        "cmd" => "mute",
        "args" => {
            "on" => on
        }
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("mute");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}

typedef RelVolume as Lang.Dictionary<Lang.String, Lang.Number>;

function sendAudioVolume(relVolume as RelVolume) as Void {
    var audioState = AudioStateImp.clone(AudioStateImp.getPendingAudioState());
    audioState["volume"] = relVolume;
    AudioStateManip.setPendingAudioState(audioState);
    var msg = {
        "cmd" => "setAudioVolume",
        "args" => {
            "volume" => relVolume
        }
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("setAudioVolume");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}