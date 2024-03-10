using Toybox.System;

(:glance, :background)
enum ActiveUiKind {
    ACTIVE_UI_NONE = "None",
    ACTIVE_UI_GLANCE = "Glance",
    ACTIVE_UI_APP = "App",
}

(:glance, :background)
var activeUiKindImp as ActiveUiKind = ACTIVE_UI_NONE;

(:glance, :background)
function getActiveUIKind() as ActiveUiKind {
    return activeUiKindImp;
}

(:glance, :background)
function setActiveUiKind(kind as ActiveUiKind) as Void {
    dump("setActiveUiKind", kind);
    if (!activeUiKindImp.equals(ACTIVE_UI_NONE)) {
        System.error("Already active UI kind: " + activeUiKindImp);
    }
    activeUiKindImp = kind;
}