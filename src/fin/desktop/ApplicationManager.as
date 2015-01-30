/**
 * Created by haseebriaz on 27/01/2015.
 */
package fin.desktop {
import fin.desktop.connection.DesktopConnection;
import fin.desktop.connection.DesktopConnectionEvent;
import fin.desktop.events.ApplicationEvent;


internal class ApplicationManager {

    private static var _instance: ApplicationManager;

    private var _connection: DesktopConnection;
    public function ApplicationManager() {

        _connection = DesktopConnection.getInstance();
        _connection.addEventListener(DesktopConnectionEvent.PROCESS_DESKTOP_EVENT, _onDesktopEvent);
    }

    public static function initialise(): void{

        if(_instance) return;
        _instance = new ApplicationManager();
    }

    private function _onDesktopEvent(event: DesktopConnectionEvent): void{

        var payload: Object = event.payload;
        if(payload.topic !== "application") return;

        var application: Application = Application.getInstances()[payload.uuid];
        application.dispatchEvent(new ApplicationEvent(payload.type, payload, application));
    }

}
}
