/**
 * Created by haseebriaz on 22/01/2015.
 */
package tests {
import fin.desktop.Notification;
import fin.desktop.NotificationOptions;
import fin.desktop.events.NotificationEvent;

public class NotificationTest {
    public function NotificationTest() {

        var notification2: Notification = new Notification(new NotificationOptions("http://demoappdirectory.openf.in/desktop/config/apps/OpenFin/HelloOpenFin/views/notification.html",
                "test message2!", "30000"));

        var notification2: Notification = new Notification(new NotificationOptions("http://demoappdirectory.openf.in/desktop/config/apps/OpenFin/HelloOpenFin/views/notification.html",
                "test message3!", "30000"));

        var notification: Notification =  new Notification(new NotificationOptions("http://demoappdirectory.openf.in/desktop/config/apps/OpenFin/HelloOpenFin/views/notification.html",
                                                    "test message1!", "60000"));

        notification.addEventListener(NotificationEvent.SHOW, onShow);
        notification.addEventListener(NotificationEvent.CLICK, onClick);
        notification.addEventListener(NotificationEvent.CLOSED, onClosed);
        notification.addEventListener(NotificationEvent.DISMISSED, onDismiss);
        notification.addEventListener(NotificationEvent.ERROR, onError);
        notification.addEventListener(NotificationEvent.MESSAGE, onMessage);

    }

    private function onShow(event: NotificationEvent): void{

        trace("notification shown");
        var notification: Notification = event.target as Notification;
        notification.sendMessage("look who's showed up!");
    }

    private function onClick(event: NotificationEvent): void{

        trace("notification clicked");
        var notification: Notification = event.target as Notification;
        notification.sendMessageToApplication("a message to application");
        notification.close();
    }

    private function onClosed(event: NotificationEvent): void{

        trace("notification closed");
    }

    private function onDismiss(event: NotificationEvent): void{

        trace("notification dismissed");
    }

    private function onError(event: NotificationEvent): void{

        trace("notification error, reason:", event.reason);
    }

    private function onMessage(event: NotificationEvent): void{

        trace("notification message", event.messsage);
    }
}
}
