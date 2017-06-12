/**
 * Created by richard on 6/9/2017.
 */
package fin.desktop.logging {
internal class TraceTarget extends AbstractTarget {
    public function TraceTarget() {
        super();
    }

    override protected function internalLog(message:String, level:Number):void{
        trace(message);
    }

}
}
