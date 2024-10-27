import Toybox.Lang;

(:inline, :background, :glance)
module InCmd {
    const syncYou as Lang.String = "syncYou";
    const subjectsChanged as Lang.String = "s";
    const acceptQueryResult as Lang.String = "a";
    const phoneStateChanged as Lang.String = "p";
    const openAppFailed as Lang.String = "f";
    const openMeCompleted as Lang.String = "c";
}

(:inline, :background)
module OpenMeCompletedArgs {
    const succeeded as Lang.String = "e";
    const messageForWakingUp as Lang.String = "m";
}