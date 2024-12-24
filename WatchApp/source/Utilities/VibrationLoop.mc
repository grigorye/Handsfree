import Toybox.Lang;
import Toybox.Timer;
import Toybox.Attention;

(:noLowMemory)
const L_VIBRA as LogComponent = "vibra";

const debugVibra = false;

(:noLowMemory)
class VibrationLoop {
    private var program as Lang.String;
    private var tail as Lang.String;
    private var vibeTimer as Timer.Timer;
    
    function initialize(program as Lang.String) {
        self.program = program.toLower() as Lang.String;
        self.tail = program;
        self.vibeTimer = new Timer.Timer();
    }

    function reduceProgram() as Void {
        if (debugVibra) { _3(L_VIBRA, "tail", tail); }
        var instructionEnd = tail.find(";");
        var instruction = substring(tail, 0, instructionEnd);
        if (debugVibra) { _3(L_VIBRA, "instruction", instruction); }

        if (instructionEnd == null) {
            if (debugVibra) { _2(L_VIBRA, "rewind"); }
            tail = program;
        } else {
            var newTailIndex = (instructionEnd as Lang.Number) + 1;
            tail = substring(tail, newTailIndex, null);
        }

        var command = substring(instruction, 0, 1);
        switch (command) {
            case "v": {
                var duration = 1000 * (substring(instruction, 1, null).toNumber() as Lang.Number);
                if (Attention has :vibrate) {
                    Attention.vibrate([new Attention.VibeProfile(100, duration)]);
                }
                if (debugVibra) { _3(L_VIBRA, "vibrate", duration); }
                vibeTimer.start(method(:reduceProgram), duration, false);
                break;
            }
            case "p":
                var pause = 1000 * (substring(instruction, 1, null).toNumber() as Lang.Number);
                if (debugVibra) { _3(L_VIBRA, "pause", pause); }
                vibeTimer.start(method(:reduceProgram), pause, false);
                break;
            default:
                break;
        }
    }

    function launch() as Void {
        if (debug) { _3(L_VIBRA, "launch", program); }
        reduceProgram();
    }

    function cancel() as Void {
        if (debug) { _3(L_VIBRA, "cancel", true); }
        vibeTimer.stop();
    }
}