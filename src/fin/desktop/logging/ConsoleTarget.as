/**
 * Created by wenjun on 6/19/2017.
 */
package fin.desktop.logging {
import flash.external.ExternalInterface;

public class ConsoleTarget extends AbstractTarget {
    public function ConsoleTarget() {
        super();
    }


    override protected function internalLog(message:String, level:Number):void {
        if(ExternalInterface.available){
            ExternalInterface.call("console.log", message);
        }
    }
}
}
