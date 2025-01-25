import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;

const onArg as Lang.String = "o";

typedef RelVolume as Lang.Dictionary<Lang.String, Lang.Number>;

module Req {

function sendMute(on as Lang.Boolean) as Void {
    var audioState = AudioStateImp.clone(AudioStateImp.getPendingAudioState());
    audioState[isMutedK] = on;
    AudioStateManip.setPendingAudioState(audioState);
    var msg = {
        cmdK => Cmd.mute,
        argsK => {
            onArg => on
        }
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("mute");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}

function sendAudioVolume(relVolume as RelVolume) as Void {
    var audioState = AudioStateImp.clone(AudioStateImp.getPendingAudioState());
    audioState[volumeK] = relVolume;
    AudioStateManip.setPendingAudioState(audioState);
    var msg = {
        cmdK => Cmd.setAudioVolume,
        argsK => {
            volumeK => relVolume
        }
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("setAudioVolume");
    if (false) {
        if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
        Communications.transmit(msg, null, new DummyCommListener(tag));
    } else {
        var proxy;
        if (audioStateLifoCommProxy != null) {
            proxy = audioStateLifoCommProxy;
        } else {
            proxy = new LifoCommProxy(new DummyCommListener("audio"));
            audioStateLifoCommProxy = proxy;
        }
        proxy.send(tag, msg);
    }
}

var audioStateLifoCommProxy as LifoCommProxy | Null = null;

}