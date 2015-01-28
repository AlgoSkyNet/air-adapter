/**
 * Created by haseebriaz on 20/01/2015.
 */
package fin.desktop.connection {
import flash.events.Event;

public class DesktopConnectionEvent extends Event{

    public static const PROCESS_DESKTOP_EVENT: String = "process-desktop-event";
    public static const PROCESS_NOTIFICATION_EVENT: String = "process-notification-event";
    public static const PROCESS_BUS_MESSAGE: String = "process-message";
    public static const SUBSCRIBER_ADDED: String = "subscriber-added";
    public static const SUBSCRIBER_REMOVED: String = "subscriber-removed";

    private var _payload: Object;

    public function DesktopConnectionEvent(type: String, payload: Object) {

        super(type);
        _payload = payload;
    }

    public function get payload(): Object{

        return _payload;
    }
}
}
