using Toybox.Attention;

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function startRequestingAttentionIfInApp() as Void {
    if (!getActiveUiKind().equals(ACTIVE_UI_APP)) {
        dump("startRequestingAttention.notInApp", true);
        return;
    }
    startRequestingAttention();
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function stopRequestingAttentionIfInApp() as Void {
    if (!getActiveUiKind().equals(ACTIVE_UI_APP)) {
        dump("stopRequestingAttention.notInApp", true);
        return;
    }
    stopRequestingAttention();
}

var activeVibrationLoop as VibrationLoop or Null;

function startRequestingAttention() as Void {
    dump("startRequestingAttention", true);
    if (activeVibrationLoop != null) {
        activeVibrationLoop.cancel();
    }
    activeVibrationLoop = new VibrationLoop(incomingCallVibrationProgram());
    activeVibrationLoop.launch();
}

function stopRequestingAttention() as Void {
    dump("stopRequestingAttention", true);
    if (activeVibrationLoop != null) {
        activeVibrationLoop.cancel();
    }
    activeVibrationLoop = null;
}
