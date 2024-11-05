import Toybox.Lang;

(:inline, :background, :glance)
module InCmd {
    const subjectsChanged = "s";
    const acceptQueryResult = "a";
    const phoneStateChanged = "p";
    const openAppFailed = "f";
    const openMeCompleted = "c";
}

(:inline, :background)
module OpenMeCompletedArgs {
    const succeeded = "e";
    const messageForWakingUp = "m";
}