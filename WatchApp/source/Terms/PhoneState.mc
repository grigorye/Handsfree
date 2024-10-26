import Toybox.Lang;

(:inline, :background, :glance)
module PhoneState {
    const stateId as Lang.String = "d";
    const number as Lang.String = "n";
    const name as Lang.String = "m";
}

(:inline, :background, :glance)
module PhoneStateId {
    const ringing as Lang.String = "r";
    const idle as Lang.String = "i";
    const offHook as Lang.String = "h";
    const unknown as Lang.String = "u";
}
