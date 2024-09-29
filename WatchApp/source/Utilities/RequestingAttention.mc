using Toybox.Attention;

(:noLowMemory)
const L_ATTN as LogComponent = "attention";

(:background, :typecheck([disableBackgroundCheck]), :noLowMemory)
function startRequestingAttentionIfInApp() as Void {
    if (!isActiveUiKindApp) {
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

var activeVibrationLoop as VibrationLoop or Null;

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
