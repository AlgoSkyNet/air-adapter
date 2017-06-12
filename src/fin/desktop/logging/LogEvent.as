/**
 * Created by richard on 6/9/2017.
 */
package fin.desktop.logging {
import flash.events.Event;


public class LogEvent extends Event {
    public static var LOG:String = "ADAPTER LOG";

    public static const ALL:Number = 0;
    public static const DEBUG:Number = 2;
    public static const INFO:Number = 4;
    public static const WARN:Number = 6;
    public static const ERROR:Number = 8;
    public static const FATAL:Number = 1000;

    private var _level:Number = LogEvent.ALL;
    private var _logger:ILogger;
    private var _data:Object;

    public function LogEvent(type:String, logger:ILogger, level:Number, data:Object) {
        super(type);
        this._data = data;
        this._logger = logger;
        this._level = level; 
    }
    
    public function get level():Number {
        return _level;
    }

    public function set level(value:Number):void {
        _level = value;
    }
    
    public function get data():Object {
        return _data;
    }
    
    public function get logger():ILogger {
        return _logger;
    }

    public static function getLevelString(value:Number):String{
        switch (value){
            case LogEvent.INFO:
                return "INFO";
            case LogEvent.DEBUG:
                return "DEBUG";
            case LogEvent.ERROR:
                return "ERROR";
            case LogEvent.WARN:
                return "WARN";
            case LogEvent.FATAL:
                return "FATAL";
            case LogEvent.ALL:
                return "ALL";
            default:
                return "UNKNOWN";
        }
    }


}
}
