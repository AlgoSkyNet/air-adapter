/**
 * Created by haseebriaz on 23/01/2015.
 */
package fin.desktop {
import fin.desktop.Window;
import fin.desktop.connection.DesktopConnection;
import fin.desktop.connection.DesktopConnectionEvent;
import fin.desktop.events.WindowEvent;

internal class WindowManager {

    private static var _instance: WindowManager;
    private var _connection: DesktopConnection;

    public function WindowManager() {

        _connection = DesktopConnection.getInstance();
        _connection.addEventListener(DesktopConnectionEvent.PROCESS_DESKTOP_EVENT, onDesktopEvent);
        _instance = this;
    }

    public static function initialise(): void{

        if(_instance) return;
        new WindowManager();
    }

    private function onDesktopEvent(event: DesktopConnectionEvent): void{

        var payload: Object = event.payload;
        if(payload.topic != "window") return;
        var window: Window = Window.getInstances()[payload.uuid + payload.name];
        window.dispatchEvent(new WindowEvent(payload.type, payload));
    }
}
}
