/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {
import fin.desktop.connection.DesktopConnection;
import fin.desktop.connection.DesktopConnectionEvent;
import fin.desktop.events.NotificationEvent;
import fin.desktop.logging.ILogger;
import fin.desktop.logging.LoggerFactory;

import flash.utils.getQualifiedClassName;

internal class NotificationManager {

    private static var _instance: NotificationManager;
    private var _connection: DesktopConnection;
    private var _logger: ILogger;
    
    public function NotificationManager() {

        _connection = DesktopConnection.getInstance();
        _connection.addEventListener(DesktopConnectionEvent.PROCESS_NOTIFICATION_EVENT, onNotificationEvent);
        _instance = this;

        _logger = LoggerFactory.getLogger(getQualifiedClassName(NotificationManager));
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

            _logger.debug("clearing notification", payload.payload.notificationId);
            Notification.getInstances()[payload.payload.notificationId] = null;
        }
    }
}
}
