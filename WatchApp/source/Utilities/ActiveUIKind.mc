using Toybox.System;
using Toybox.Lang;

(:glance, :background)
const L_UI_KIND as LogComponent = "uiKind";

(:glance, :background)
enum ActiveUiKind {
    ACTIVE_UI_NONE = "None",
    ACTIVE_UI_GLANCE = "Glance",
    ACTIVE_UI_APP = "App",
}

(:glance, :background)
var activeUiKindImp as ActiveUiKind = ACTIVE_UI_NONE;

(:glance, :background)
function getActiveUiKind() as ActiveUiKind {
    return activeUiKindImp;
}

(:glance)
function setActiveUiKind(kind as ActiveUiKind) as Void {
    _3(L_UI_KIND, "setActiveUiKind", kind);
    if (!activeUiKindImp.equals(ACTIVE_UI_NONE)) {
        System.error("Already active UI kind: " + activeUiKindImp);
    }
    activeUiKindImp = kind;
}

(:background, :glance)
function isActiveUiKindApp() as Lang.Boolean {
    return activeUiKindImp.equals(ACTIVE_UI_APP);
}
