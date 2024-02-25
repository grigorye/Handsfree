using Toybox.Lang;

class HangingUp extends CallStateImp {
    var commStatus as CommStatus;
    
    function initialize(commStatus as CommStatus) {
        CallStateImp.initialize();
        self.commStatus = commStatus;
    }

    function clone() as HangingUp {
        return new HangingUp(commStatus);
    }

    function dumpRep() as Lang.String {
        return "HangingUp(" + commStatus + ")";
    }
}
