import Toybox.Lang;

(:background)
var lastSelectedAudioVolumeImp as RelVolume | Null = null;

(:background)
function setLastSelectedAudioVolume(lastSelectedAudioVolume as RelVolume) as Void {
    lastSelectedAudioVolumeImp = lastSelectedAudioVolume;
}

function getLastSelectedAudioVolume() as RelVolume | Null {
    return lastSelectedAudioVolumeImp;
}