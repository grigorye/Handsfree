using Toybox.Lang;
using Toybox.Timer;
using Toybox.Attention;

const L_VIBRA as LogComponent = "vibra";

class VibrationLoop {
    var program as Lang.String;
    var tail as Lang.String;
    var ip as Lang.Number = 0;
    var vibeTimer as Timer.Timer;
    var shouldCancel as Lang.Boolean = false;
    
    function initialize(program as Lang.String) {
        self.program = program.toLower() as Lang.String;
        self.tail = program;
        self.vibeTimer = new Timer.Timer();
    }

    function reduceProgram() as Void {
        _3(L_VIBRA, "tail", tail);
        var instructionEnd = tail.find(";");
        var instruction = substring(tail, 0, instructionEnd);
        _3(L_VIBRA, "instruction", instruction);

        if (instructionEnd == null) {
            _2(L_VIBRA, "rewind");
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
                _3(L_VIBRA, "vibrate", duration);
                vibeTimer.start(method(:reduceProgram), duration, false);
                break;
            }
            case "p":
                var pause = 1000 * (substring(instruction, 1, null).toNumber() as Lang.Number);
                _3(L_VIBRA, "pause", pause);
                vibeTimer.start(method(:reduceProgram), pause, false);
                break;
            default:
                break;
        }
    }

    function launch() as Void {
        _3(L_VIBRA, "launch", program);
        reduceProgram();
    }

    function cancel() as Void {
        _3(L_VIBRA, "cancel", true);
        shouldCancel = true;
        vibeTimer.stop();
    }
}