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
    };
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
    };
    transmitWithLifo("setAudioVolume", msg);
}

function transmitWithLifo(tagLiteral as Lang.String, msg as Lang.Object) as Void {
    var proxy;
    var existingProxy = lifoCommProxies[tagLiteral];
    if (existingProxy != null) {
        proxy = existingProxy;
    } else {
        proxy = new LifoCommProxy(new DummyCommListener(tagLiteral));
        lifoCommProxies[tagLiteral] = proxy;
    }
    var tag = formatCommTag(tagLiteral);
    proxy.send(tag, msg as Application.PersistableType);
}

var lifoCommProxies as Lang.Dictionary<Lang.String, LifoCommProxy> = {} as Lang.Dictionary<Lang.String, LifoCommProxy>;

}