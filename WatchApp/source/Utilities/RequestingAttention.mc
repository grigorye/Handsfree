import Toybox.Attention;
import Toybox.Lang;

(:noLowMemory)
const L_ATTN as LogComponent = "attention";

(:background, :typecheck([disableBackgroundCheck]), :noLowMemory)
function startRequestingAttentionIfInAppAndNotDeactivated() as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    if (isRequestingAttentionDeactivatedTillRelaunch) {
        if (debug) { _2(L_ATTN, "requestingAttentionDeactivatedTillRelaunch"); }
        return;
    }
    startRequestingAttention();
}

(:background, :typecheck([disableBackgroundCheck]), :noLowMemory)
function stopRequestingAttentionIfInApp() as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    stopRequestingAttention();
}

(:noLowMemory)
var activeVibrationLoop as VibrationLoop or Null;

(:noLowMemory)
var isRequestingAttentionDeactivatedTillRelaunch as Lang.Boolean = false;

(:noLowMemory)
function startRequestingAttention() as Void {
    if (debug) { _2(L_ATTN, "startRequestingAttention"); }
    if (activeVibrationLoop != null) {
        activeVibrationLoop.cancel();
    }
    activeVibrationLoop = new VibrationLoop(AppSettings.incomingCallVibrationProgram);
    activeVibrationLoop.launch();
}

(:noLowMemory)
function stopRequestingAttention() as Void {
    if (debug) { _2(L_ATTN, "stopRequestingAttention"); }
    if (activeVibrationLoop != null) {
        activeVibrationLoop.cancel();
    }
    activeVibrationLoop = null;
}

(:noLowMemory)
function deactivateRequestingAttentionTillRelaunch() as Void {
    stopRequestingAttention();
    if (debug) { _2(L_ATTN, "blockRequestingAttention"); }
    isRequestingAttentionDeactivatedTillRelaunch = true;
}
