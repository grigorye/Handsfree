using Toybox.Attention;

enum BeepType {
    BEEP_TYPE_BEEP,
    BEEP_TYPE_ERROR,
    BEEP_TYPE_SUCCESS,
    BEEP_TYPE_MESSAGE
}

function beep(type as BeepType) as Void {
    if (!getActiveUiKind().equals(ACTIVE_UI_APP)) {
        return;
    }
    if (!(Attention has :playTone)) {
        return;
    }
    var tone = toneForBeep(type);
    Attention.playTone(tone);
}

function toneForBeep(type as BeepType) as Attention.Tone {
    switch (type) {
        case BEEP_TYPE_BEEP: {
            return Attention.TONE_LOUD_BEEP;
        }
        case BEEP_TYPE_ERROR: {
            return Attention.TONE_ERROR;
        }
        case BEEP_TYPE_SUCCESS: {
            return Attention.TONE_KEY;
        }
        case BEEP_TYPE_MESSAGE: {
            return Attention.TONE_MSG;
        }
        default: {
            return Attention.TONE_LOUD_BEEP;
        }
    }
}