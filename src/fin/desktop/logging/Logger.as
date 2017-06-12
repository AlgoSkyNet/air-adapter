/**
 * Created by wche on 6/9/2017.
 */
package fin.desktop.logging {
import flash.events.EventDispatcher;

internal class Logger extends EventDispatcher implements ILogger {
    private var _category: String;

    public function Logger(category:String) {
        super();
        this._category = category;
    }

    public function get category():String {
        return _category;
    }

    public function log(level:Number, ...rest):void {
        if(level == undefined || level < LogEvent.DEBUG){
            throw new ArgumentError('Invalid logging LogEventLevel');
        }
        dispatchEvent(new LogEvent(LogEvent.LOG, this, level, { message: generateLogString.apply(this, rest) }));
    }

    private function generateLogString(...args):String {
        var msg:String = "";
        for (var i:uint = 0; i < args.length; i++) {
            msg = msg.concat(args[i]);
            msg = msg.concat(" ");
        }
        return msg;
    }

    public function debug(...args):void {
        args.unshift(LogEvent.DEBUG);
        log.apply(this, args);
    }

    public function info(...args):void {
        args.unshift(LogEvent.INFO);
        log.apply(this, args);
    }

    public function warn(...args):void {
        args.unshift(LogEvent.WARN);
        log.apply(this, args);
    }

    public function error(...args):void {
        args.unshift(LogEvent.ERROR);
        log.apply(this, args);
    }

    public function fatal(...args):void {
        args.unshift(LogEvent.FATAL);
        log.apply(this, args);
    }
}
}
