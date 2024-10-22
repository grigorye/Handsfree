import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;

const onArg as Lang.String = "o";

function sendMute(on as Lang.Boolean) as Void {
    var audioState = AudioStateImp.clone(AudioStateImp.getPendingAudioState());
    audioState[isMutedK] = on;
    AudioStateManip.setPendingAudioState(audioState);
    var msg = {
        cmdK => muteCmd,
        argsK => {
            onArg => on
        }
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("mute");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}

typedef RelVolume as Lang.Dictionary<Lang.String, Lang.Number>;

function sendAudioVolume(relVolume as RelVolume) as Void {
    var audioState = AudioStateImp.clone(AudioStateImp.getPendingAudioState());
    audioState[volumeK] = relVolume;
    AudioStateManip.setPendingAudioState(audioState);
    var msg = {
        cmdK => setAudioVolumeCmd,
        argsK => {
            volumeK => relVolume
        }
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("setAudioVolume");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}