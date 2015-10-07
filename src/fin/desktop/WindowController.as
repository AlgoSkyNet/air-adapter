/**
 * Created by haseebriaz on 04/06/2015.
 */
package fin.desktop {

import flash.events.EventDispatcher;
import flash.external.ExtensionContext;

public class WindowController extends EventDispatcher{

    private var context: ExtensionContext;
    public function WindowController() {

        context = ExtensionContext.createExtensionContext("fin.desktop.WindowController", "");
    }

    private function init(): void{

        context.call("init");
    }

    public function getHwnd(): String{

       return  String(context.call("getHWND"));
    }
}
}
