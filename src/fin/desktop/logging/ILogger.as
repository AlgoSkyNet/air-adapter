/**
 * Created by wche on 6/9/2017.
 */

package fin.desktop.logging {
import flash.events.IEventDispatcher;

public interface ILogger extends IEventDispatcher{

    function log(level:Number, ...rest):void;

    function debug(...args):void;

    function info(...args):void;

    function warn(...args):void;

    function error(...args):void;

    function fatal(...args):void;
}
}
