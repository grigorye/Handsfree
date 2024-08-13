using Toybox.Attention;

const L_ATTN as LogComponent = "attention";

(:background, :typecheck([disableBackgroundCheck]))
function startRequestingAttentionIfInApp() as Void {
    if (!isActiveUiKindApp()) {
        return;
    }
    startRequestingAttention();
}

(:background, :typecheck([disableBackgroundCheck]))
function stopRequestingAttentionIfInApp() as Void {
    if (!isActiveUiKindApp()) {
        return;
    }
    stopRequestingAttention();
}

var activeVibrationLoop as VibrationLoop or Null;

function startRequestingAttention() as Void {
    _2(L_ATTN, "startRequestingAttention");
    if (activeVibrationLoop != null) {
        activeVibrationLoop.cancel();
    }
    activeVibrationLoop = new VibrationLoop(incomingCallVibrationProgram());
    activeVibrationLoop.launch();
}

function stopRequestingAttention() as Void {
    _2(L_ATTN, "stopRequestingAttention");
    if (activeVibrationLoop != null) {
        activeVibrationLoop.cancel();
    }
    activeVibrationLoop = null;
}
