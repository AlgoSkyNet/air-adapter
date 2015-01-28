/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {
import fin.desktop.connection.DesktopConnection;
import fin.desktop.connection.DesktopConnectionEvent;
import fin.desktop.events.NotificationEvent;

internal class NotificationManager {

    private static var _instance: NotificationManager;
    private var _connection: DesktopConnection;

    public function NotificationManager() {

        _connection = DesktopConnection.getInstance();
        _connection.addEventListener(DesktopConnectionEvent.PROCESS_NOTIFICATION_EVENT, onNotificationEvent);
        _instance = this;
    }

    public static function initialise(): void{

        if(_instance) return;
        new NotificationManager();
    }

    private function onNotificationEvent(event: DesktopConnectionEvent): void {

        var payload:Object = event.payload.payload;
        var id:int = payload.notificationId;
        var notification:Notification = Notification.getInstances()[id];

        notification.dispatchEvent(new NotificationEvent(event.payload.type, id, payload.message, payload.reason));

        destroyIfNotRequired(event.payload);
    }

    private function destroyIfNotRequired(payload: Object): void{

        if(payload.type === NotificationEvent.CLOSED || payload.type === NotificationEvent.DISMISSED){

            trace("clearing notification", payload.payload.notificationId);
            Notification.getInstances()[payload.payload.notificationId] = null;
        }
    }
}
}
