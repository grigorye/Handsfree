using Toybox.Lang;
using Toybox.Timer;
using Toybox.Attention;

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
        dump("vibrationLoop.tail", tail);
        var instructionEnd = tail.find(";");
        var instruction = tail.substring(0, instructionEnd) as Lang.String;
        dump("vibrationLoop.instruction", instruction);

        if (instructionEnd == null) {
            dump("vibrationLoop.rewind", true);
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
                dump("vibrationLoop.vibrate", duration);
                vibeTimer.start(method(:reduceProgram), duration, false);
                break;
            }
            case "p":
                var pause = 1000 * (instruction.substring(1, null) as Lang.String).toNumber() as Lang.Number;
                dump("vibrationLoop.pause", pause);
                vibeTimer.start(method(:reduceProgram), pause, false);
                break;
            default:
                break;
        }
    }

    function launch() as Void {
        dump("vibrationLoop.launch", program);
        reduceProgram();
    }

    function cancel() as Void {
        dump("vibrationLoop.cancel", true);
        shouldCancel = true;
        vibeTimer.stop();
    }
}