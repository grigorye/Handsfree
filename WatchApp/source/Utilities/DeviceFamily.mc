import Toybox.Lang;

(:background, :glance)
module DeviceFamily {

(:noFenix7)
const noFenix7 = true;

}

(:background, :glance)
const isFenix7 as Lang.Boolean = !(DeviceFamily has :noFenix7);
