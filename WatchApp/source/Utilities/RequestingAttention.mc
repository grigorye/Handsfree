using Toybox.Attention;

const L_ATTN as LogComponent = "attention";

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function startRequestingAttentionIfInApp() as Void {
    if (!getActiveUiKind().equals(ACTIVE_UI_APP)) {
        _([L_ATTN, "startRequestingAttention", "notInApp"]);
        return;
    }
    startRequestingAttention();
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function stopRequestingAttentionIfInApp() as Void {
    if (!getActiveUiKind().equals(ACTIVE_UI_APP)) {
        _([L_ATTN, "stopRequestingAttention", "notInApp"]);
        return;
    }
    stopRequestingAttention();
}

var activeVibrationLoop as VibrationLoop or Null;

function startRequestingAttention() as Void {
    _([L_ATTN, "startRequestingAttention"]);
    if (activeVibrationLoop != null) {
        activeVibrationLoop.cancel();
    }
    activeVibrationLoop = new VibrationLoop(incomingCallVibrationProgram());
    activeVibrationLoop.launch();
}

function stopRequestingAttention() as Void {
    _([L_ATTN, "stopRequestingAttention"]);
    if (activeVibrationLoop != null) {
        activeVibrationLoop.cancel();
    }
    activeVibrationLoop = null;
}
