/**
 * Created by wche on 6/9/2017.
 */
package fin.desktop.logging {
internal interface ITarget {
    function addLogger(logger:ILogger):void;
    function removeLogger(logger:ILogger):void;
}
}
