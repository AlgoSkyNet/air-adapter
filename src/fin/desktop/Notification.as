/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {

import fin.desktop.connection.DesktopConnection;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class Notification extends EventDispatcher{

    private static var _instances: Dictionary = new Dictionary();

    private var _id: int;

    public static function getInstances(): Dictionary{

        return _instances;
    }

    public function Notification(options: NotificationOptions) {

        NotificationManager.initialise();

        sendMessageToNotificationCenter("create-notification", options);

        _id = options.notificationId;
        _instances[options.notificationId] = this;
    }

    private static function sendMessageToNotificationCenter(action: String, payload: Object, callback: Function = null, errorCallback: Function = null){

        DesktopConnection.getInstance().sendMessage("send-action-to-notifications-center",{action: action, payload: payload}, callback, errorCallback);
    }

    public function sendMessage(message: Object, callback: Function = null, errorCallback: Function = null): void{

        sendMessageToNotificationCenter("send-notification-message", {message: message, notificationId: _id}, callback, errorCallback);
    }

    public function sendMessageToApplication(message: Object, callback: Function = null, errorCallback: Function = null): void{

        sendMessageToNotificationCenter("send-application-message", {message: message, notificationId: _id}, callback, errorCallback);
    }

    public function close(callback: Function = null, errorCallback: Function = null): void{

        sendMessageToNotificationCenter("close-notification", {notificationId: _id}, callback, errorCallback);
    }
}
}
