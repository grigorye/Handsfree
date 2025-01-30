import Toybox.Lang;
import Toybox.Application;

module Req {

function transmitWithLifo(tagLiteral as Lang.String, msg as Lang.Object) as Void {
    var proxy;
    var existingProxy = lifoCommProxies[tagLiteral];
    if (existingProxy != null) {
        proxy = existingProxy;
    } else {
        proxy = new LifoCommProxy(new DummyCommListener(tagLiteral));
        lifoCommProxies[tagLiteral] = proxy;
    }
    var tag = formatCommTag(tagLiteral);
    proxy.send(tag, msg as Application.PersistableType);
}

var lifoCommProxies as Lang.Dictionary<Lang.String, LifoCommProxy> = {} as Lang.Dictionary<Lang.String, LifoCommProxy>;

}