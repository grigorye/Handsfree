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
        _([L_VIBRA, "tail", tail]);
        var instructionEnd = tail.find(";");
        var instruction = tail.substring(0, instructionEnd) as Lang.String;
        _([L_VIBRA, "instruction", instruction]);

        if (instructionEnd == null) {
            _([L_VIBRA, "rewind"]);
            tail = program;
        } else {
            var newTailIndex = (instructionEnd as Lang.Number) + 1;
            tail = tail.substring(newTailIndex, null) as Lang.String;
        }

        var command = instruction.substring(0, 1) as Lang.String;
        switch (command) {
            case "v": {
                var duration = 1000 * (instruction.substring(1, null) as Lang.String).toNumber() as Lang.Number;
                Attention.vibrate([new Attention.VibeProfile(100, duration)]);
                _([L_VIBRA, "vibrate", duration]);
                vibeTimer.start(method(:reduceProgram), duration, false);
                break;
            }
            case "p":
                var pause = 1000 * (instruction.substring(1, null) as Lang.String).toNumber() as Lang.Number;
                _([L_VIBRA, "pause", pause]);
                vibeTimer.start(method(:reduceProgram), pause, false);
                break;
            default:
                break;
        }
    }

    function launch() as Void {
        _([L_VIBRA, "launch", program]);
        reduceProgram();
    }

    function cancel() as Void {
        _([L_VIBRA, "cancel", true]);
        shouldCancel = true;
        vibeTimer.stop();
    }
}