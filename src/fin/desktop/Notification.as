/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {

import fin.desktop.connection.DesktopConnection;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

/**
 *
 * A Notification represents a window which is shown briefly
 * to the user on the bottom-right corner of the primary monitor.
 * A notification is typically used to alert the user of some important event
 * which requires his or her attention.
 *
 *  Multiple notifications can be generated at once but will queue if more
 * than 5 are already displayed. Notifications can be dismissed by dragging
 * them to the right with the mouse and can communicate securely with their
 * invoking applications.
 *
 */
public class Notification extends EventDispatcher{

    private static var _instances: Dictionary = new Dictionary();

    private var _id: int;

    public static function getInstances(): Dictionary{

        return _instances;
    }

    /**
     * Notification constructor
     * @param notificationOptions The options of this notification
     * @param callback A function that is called if successful in creating the notification
     * @param errorCallback A function that is called if the method fails
     * @event CLICK fin.desktop.events.NotificationEvent [dispatched when user clicks on the notification]
     * @event CLOSED fin.desktop.events.NotificationEvent [dispatched when notification is closed]
     * @event DISMISSED fin.desktop.events.NotificationEvent [dispatched when dismissed by the user]
     * @event ERROR fin.desktop.events.NotificationEvent [dispatched if there is an error]
     * @event MESSAGE fin.desktop.events.NotificationEvent [dispatched when a message is received from the notification ]
     * @event SHOW fin.desktop.events.NotificationEvent [dispatched notification is shown]
     */
    public function Notification(options: NotificationOptions, callback: Function = null, errorCallback: Function = null) {

        NotificationManager.initialise();

        sendMessageToNotificationCenter("create-notification", options, callback, errorCallback);

        _id = options.notificationId;
        _instances[options.notificationId] = this;
    }

    private static function sendMessageToNotificationCenter(action: String, payload: Object, callback: Function = null, errorCallback: Function = null){

        DesktopConnection.getInstance().sendMessage("send-action-to-notifications-center",{action: action, payload: payload}, callback, errorCallback);
    }

    /**
     *
     * Sends a message to the notification
     *
     * @param message The JSON message to be sent to the notification
     * @param callback A function that is called if successful.
     * @param callback A function that is called if action failed.
     */
    public function sendMessage(message: Object, callback: Function = null, errorCallback: Function = null): void{

        sendMessageToNotificationCenter("send-notification-message", {message: message, notificationId: _id}, callback, errorCallback);
    }

    /**
     *
     * Sends a message from the notification to the application that
     * created the notification. The message is handled by the
     * notification's onMessage callback.
     *
     * @param message The JSON message to be sent to the application
     * @param callback A function that is called if successful.
     * @param callback A function that is called if action failed.
     */
    public function sendMessageToApplication(message: Object, callback: Function = null, errorCallback: Function = null): void{

        sendMessageToNotificationCenter("send-application-message", {message: message, notificationId: _id}, callback, errorCallback);
    }

    /**
     *
     * Closes the notification
     *
     * @param callback A function that is called if successful.
     * @param callback A function that is called if action failed.
     */
    public function close(callback: Function = null, errorCallback: Function = null): void{

        sendMessageToNotificationCenter("close-notification", {notificationId: _id}, callback, errorCallback);
    }
}
}
