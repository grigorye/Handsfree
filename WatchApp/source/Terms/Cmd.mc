import Toybox.Lang;

(:inline, :background, :glance)
module Cmd {
    const call as Lang.String = "c";
    const hangup as Lang.String = "h";
    const accept as Lang.String = "a";
    const mute as Lang.String = "m";
    const setAudioVolume as Lang.String = "v";
    const didFirstLaunch as Lang.String = "l";
    const query as Lang.String = "q";
    const openMe as Lang.String = "o";
    const openAppInStore as Lang.String = "r";
}

(:inline, :background, :glance)
module CallArgsK {
    const number as Lang.String = "n";
}

(:inline, :background, :glance)
module QueryArgsK {
    const subjects as Lang.String = "n";
    const subjectNameK as Lang.String = "n";
    const subjectVersionK as Lang.String = "v";
}

(:inline, :background, :glance)
module OpenMeArgsK {
    const messageForWakingUp as Lang.String = "m";
}
