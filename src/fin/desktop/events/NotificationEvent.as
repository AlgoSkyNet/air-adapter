/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop.events {
import flash.events.Event;

public class NotificationEvent extends Event {

    public static const CLICK: String = "click";
    public static const CLOSED: String = "close";
    public static const DISMISSED: String = "dismiss";
    public static const ERROR: String = "error";
    public static const MESSAGE: String = "message";
    public static const SHOW: String = "show";

    private var _notificationId: int;
    private var _reason: String;
    private var _messsage: String;

    public function NotificationEvent(type: String, notificationId: int,  message: String = null, reason :String = null) {

        super(type);

        _notificationId = notificationId;
        _reason = reason;
        _messsage = message;
    }

    public function get notificationId():int {

        return _notificationId;
    }

    public function get reason():String {

        return _reason;
    }

    public function get messsage():String {

        return _messsage;
    }
}
}
