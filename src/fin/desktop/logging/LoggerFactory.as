/**
 * Created by wche on 6/9/2017.
 */
package fin.desktop.logging {

public class LoggerFactory {

    private static var _loggers:Array = new Array();
    private static var _targets:Array = new Array();

    public static function getLogger(category:String):ILogger {
        if(_loggers[category] == undefined){
            _loggers[category] = new Logger(category);
            var target:AbstractTarget;
            for(var i:Number = 0; i < _targets.length; i++){
                target = _targets[i];
                target.addLogger(_loggers[category]);
            }
        }
        return _loggers[category];
    }

    public static function addTarget(target:AbstractTarget):void{
        if(target){
            if(!LoggerFactory.hasTarget(target)){
                // check if we already have filters matching this target
                for(var category:String in _loggers){
                    target.addLogger(_loggers[category]);
                }
                // add to queue
                _targets.push(target);
            }
        }else{
            throw new ArgumentError('Invalid target for logging');
        }
    }

    public static function removeTarget(target:AbstractTarget):void{
        if(target){
            for(var i:Number = 0; i < _targets.length; i++){
                if(target == _targets[i]){
                    _targets.splice(i, 1);
                    i--;
                }
            }
        }else{
            throw new ArgumentError('Invalid target for logging');
        }
    }

    public static function hasTarget(target:AbstractTarget):Boolean{
        for(var i:Number = 0; i < _targets.length; i++){
            if(target == _targets[i]) return true;
        }
        return false;
    }

    public static function addTraceLogger(level:Number=LogEvent.DEBUG):void {
        var target: TraceTarget = new TraceTarget();
        target.level = level;
        addTarget(target);
    }

    public static function addFileLogger(logFileName:String=null, level:Number=LogEvent.DEBUG):void {
        var target: FileTarget = new FileTarget(logFileName);
        target.level = level;
        addTarget(target);
    }

}
}
