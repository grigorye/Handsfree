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
        cmdK => Cmd_mute,
        argsK => {
            onArg => on
        }
    } as Lang.Object as Application.PersistableType;
    transmitWithoutRetry("mute", msg);
}

function sendAudioVolume(relVolume as RelVolume) as Void {
    var audioState = AudioStateImp.clone(AudioStateImp.getPendingAudioState());
    audioState[volumeK] = relVolume;
    AudioStateManip.setPendingAudioState(audioState);
    var msg = {
        cmdK => Cmd_setAudioVolume,
        argsK => {
            volumeK => relVolume
        }
    } as Lang.Object as Application.PersistableType;
    transmitWithLifo("setAudioVolume", msg);
}

function transmitWithLifo(tagLiteral as Lang.String, msg as Application.PersistableType) as Void {
    var proxy;
    var existingProxy = lifoCommProxies[tagLiteral];
    if (existingProxy != null) {
        proxy = existingProxy;
    } else {
        proxy = new LifoCommProxy(new DummyCommListener(tagLiteral));
        lifoCommProxies[tagLiteral] = proxy;
    }
    var tag = formatCommTag(tagLiteral);
    proxy.send(tag, msg);
}

var lifoCommProxies as Lang.Dictionary<Lang.String, LifoCommProxy> = {} as Lang.Dictionary<Lang.String, LifoCommProxy>;

}