import Toybox.Lang;

(:inline, :background, :glance)
module Cmd {
    const call = "c";
    const hangup = "h";
    const accept = "a";
    const mute = "m";
    const setAudioVolume = "v";
    const didFirstLaunch = "l";
    const pong = "g";
    const query = "q";
    const openMe = "o";
    const openAppInStore = "r";
}

(:inline, :background, :glance)
module CallArgsK {
    const number = "n";
}

(:inline, :background, :glance)
module QueryArgsK {
    const subjects = "n";
    const subjectNameK = "n";
    const subjectVersionK = "v";
}

(:inline, :background, :glance)
module OpenMeArgsK {
    const messageForWakingUp = "m";
}
