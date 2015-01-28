/**
 * Created by haseebriaz on 23/01/2015.
 */
package fin.desktop.events {
import flash.events.Event;

public class WindowEvent extends  Event{

    public static const BLURRED: String = "blurred";
    public static const BOUNDS_CHANGED: String = "bounds-changed";
    public static const BOUNDS_CHANGING: String = "bounds-changing";
    public static const CLOSED: String = "closed";
    public static const CLOSE_REQUESTED: String = "close-requested";
    public static const DISABLED_FRAME_BOUNDS_CHANGED: String = "disabled-frame-bounds-changed";
    public static const DISABLED_FRAME_BOUNDS_CHANGING: String = "disabled-frame-bounds-changing";
    public static const FOCUSED: String = "focused";
    public static const FRAME_DISABLED: String = "frame-disabled";
    public static const FRAME_ENABLED: String = "frame-enabled";
    public static const GROUP_CHANGED: String = "group-changed";
    public static const HIDDEN: String = "hidden";
    public static const MAXIMIZED: String = "maximized";
    public static const MINIMIZED: String = "minimized";
    public static const RESTORED: String = "restored";
    public static const SHOWN: String = "shown";

    private var _payload: Object;

    public function WindowEvent(type: String, payload: Object) {

        super(type);
        _payload = payload;
    }

    public function get payload(): Object{

        return _payload;
    }
}
}
