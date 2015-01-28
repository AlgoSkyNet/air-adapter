/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {
public class NotificationOptions {

    private static var ID: int = 0;

    private var _url: String;
    private var _message: String;
    private var _timeout: String;
    private var _notificationId: int;

    public function NotificationOptions( url: String, message: String = null, timeout: String = "never" ): void {

        _url = url;
        _message = message;
        _timeout = timeout;
        _notificationId = ID++;
    }

    public function get url(): String{
        return _url;
    }

    public function get message():String {
        return _message;
    }

    public function get timeout():String {
        return _timeout;
    }

    public function get notificationId():int {
        return _notificationId;
    }
}
}
