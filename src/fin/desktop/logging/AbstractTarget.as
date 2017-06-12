/**
 * Created by richard on 6/9/2017.
 */
package fin.desktop.logging {
internal class AbstractTarget implements ITarget {
    public var fieldSeparator:String = " ";
    public var includeTime:Boolean = true;
    public var includeDate:Boolean = true;
    public var includeCategory:Boolean = true;
    public var includeLevel:Boolean = true;

    private var _level:Number = LogEvent.ALL;

    public function AbstractTarget() {
    }

    public function addLogger(logger:ILogger):void {
        if(logger){
            logger.addEventListener(LogEvent.LOG,  logHandler);
        }
    }

    public function removeLogger(logger:ILogger):void {
        if(logger){
            logger.removeEventListener(LogEvent.LOG,  logHandler);
        }
    }

    public function logEvent(event:LogEvent):void{
        var date:String = '';
        var levelCategory:String = '';
        if (includeDate || includeTime){
            var d:Date = new Date();
            date += '[';
            if(includeDate){
                date += d.getDate().toString() + '/';
                date += Number(d.getMonth() + 1).toString() + '/';
                date += d.getFullYear().toString();
                date += fieldSeparator;
            }
            if(includeTime){
                date += padTime(d.getHours()) + ':';
                date += padTime(d.getMinutes()) + ':';
                date += padTime(d.getSeconds()) + ':';
                date += padTime(d.getMilliseconds(), true);
                date += fieldSeparator;
            }
            date += ']';
        }
        levelCategory += '[' + LogEvent.getLevelString(event.level) + ':';
        levelCategory += Logger(event.logger).category + ']' + fieldSeparator;
        internalLog(date + levelCategory + event.data.message, event.level);
    }

    private function padTime(value:Number, milliseconds:Boolean = false):String{
        if(milliseconds || false){
            if(value < 10){
                return '00' + value.toString();
            }else if(value < 100){
                return '0' + value.toString();
            }else{
                return value.toString();
            }
        }else{
            return value > 9 ? value.toString() : '0' + value.toString();
        }
    }

    private function logHandler(event:LogEvent):void{
        if (event.level >= level) {
            logEvent(event);
        }
    }

    public function get level():Number{
        return _level;
    }
    
    public function set level(value:Number):void{
        LoggerFactory.removeTarget(this);
        _level = value;
        LoggerFactory.addTarget(this);
    }

    protected function internalLog(message:String, level:Number):void{
        // override this method to perform the redirection to the desired output
    }

}
}
