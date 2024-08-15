using Toybox.System;
using Toybox.Lang;

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
    _3(LX_UI_KIND, "setActiveUiKind", kind);
    if (!activeUiKind.equals(ACTIVE_UI_NONE)) {
        System.error("Already active UI kind: " + activeUiKind);
    }
    activeUiKind = kind;
    isActiveUiKindApp = activeUiKind.equals(ACTIVE_UI_APP);
}

// Exposed for direct read-only access for (code space) optimization, set by setActiveUiKind.
(:background, :glance)
var isActiveUiKindApp as Lang.Boolean = false;
