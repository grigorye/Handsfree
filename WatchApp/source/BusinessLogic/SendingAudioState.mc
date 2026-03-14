import Toybox.Lang;

const onArg as Lang.String = "o";

typedef RelVolume as Lang.Dictionary<Lang.String, Lang.Number>;

module Req {

function sendMute(on as Lang.Boolean) as Void {
    var audioState = AudioStateImp.clone(AudioStateImp.getPendingAudioState());
    audioState[isMutedK] = on;
    AudioStateManip.setPendingAudioState(audioState);
    var msg = {
        cmdK => Cmd_mute,
        onArg => on
    };
    transmitWithoutRetry("mute", msg);
}

function sendAudioVolume(relVolume as RelVolume) as Void {
    var audioState = AudioStateImp.clone(AudioStateImp.getPendingAudioState());
    audioState[volumeK] = relVolume;
    AudioStateManip.setPendingAudioState(audioState);
    var msg = {
        cmdK => Cmd_setAudioVolume,
        volumeK => relVolume
    };
    transmitWithLifo("setAudioVolume", msg);
}

}