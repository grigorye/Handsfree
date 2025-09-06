import Toybox.System;
import Toybox.Lang;

(:glance, :background)
const LX_UI_KIND as LogComponent = "app";

(:glance, :background)
enum ActiveUiKind {
    ACTIVE_UI_NONE = "None",
    ACTIVE_UI_GLANCE = "Glance",
    ACTIVE_UI_APP = "App",
}

// Exposed for direct read-only access for (code space) optimization, set by setActiveUiKind.
(:glance, :background)
var activeUiKind as ActiveUiKind = ACTIVE_UI_NONE;

(:glance)
function setActiveUiKind(kind as ActiveUiKind) as Void {
    if (minDebug) { _3(LX_UI_KIND, "activeUiKind", kind); }
    if (!activeUiKind.equals(ACTIVE_UI_NONE)) {
        if (testDebug) {
            System.error("Already active UI kind: " + activeUiKind);
        } else {
            System.error("");
        }
    }
    activeUiKind = kind;
    isActiveUiKindApp = activeUiKind.equals(ACTIVE_UI_APP);
    activeUIKindDidChange();
}

// Exposed for direct read-only access for (code space) optimization, set by setActiveUiKind.
(:background, :glance)
var isActiveUiKindApp as Lang.Boolean = false;
