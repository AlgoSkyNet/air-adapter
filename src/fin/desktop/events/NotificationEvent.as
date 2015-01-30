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
    private var _messsage: *;


    public function NotificationEvent(type: String, notificationId: int,  message: * = null, reason :String = null) {

        super(type);

        _notificationId = notificationId;
        _reason = reason;
        _messsage = message;
    }

    /**
     * ID of the notification that dispatched the event.
     */
    public function get notificationId():int {

        return _notificationId;
    }

    /**
     * if it's an error event, reason will be populated with the description of the cause of the error.
     */
    public function get reason():String {

        return _reason;
    }

    /**
     * Content of the message received from notification. it can either be String or an Object.
     */
    public function get messsage():* {

        return _messsage;
    }
}
}
