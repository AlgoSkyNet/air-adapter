/**
 * Created by haseebriaz on 22/01/2015.
 */
package tests {
import fin.desktop.Application;
import fin.desktop.ApplicationOptions;
import fin.desktop.Window;
import fin.desktop.WindowOptions;
import fin.desktop.events.WindowEvent;

public class WindowTests {
    public function WindowTests() {
        addApplication();
    }
    private var app: Application;
    private var appWindow: Window;

    private function addApplication( ) : void {

        var appUuid:String = "testUID";
        var applicationOptions:ApplicationOptions = new ApplicationOptions("child45", "http://www.google.com");

        var windowOptions:WindowOptions = new WindowOptions();
        windowOptions.minimizable = true;
        windowOptions.maximizable = true;
        windowOptions.autoShow = true;
        windowOptions.resizable = true;
        windowOptions.showTaskbarIcon = true;
        windowOptions.frame = true;
        windowOptions.draggable = true;
        applicationOptions.mainWindowOptions = windowOptions;
        app = new Application(applicationOptions, showApp, function(reason: String){
            trace("could not create the application, reason:", reason);
        });
    }

    private function showApp(): void{

        app.run();

        //ADD EVENT LISTENER TO WINDOW CHANGES
        trace("test");
        appWindow = app.window;

        trace(appWindow)
        appWindow.show();
        appWindow.addEventListener(WindowEvent.BOUNDS_CHANGED, onBoundsChanged );
        appWindow.addEventListener(WindowEvent.BOUNDS_CHANGING, onBoundsChanging );
        appWindow.moveTo(50,50);

    }

    public function onBoundsChanged(event : WindowEvent): void
    {
        trace("On Bounds Changed ");
    }

    public function onBoundsChanging( event : WindowEvent ) : void
    {
        trace("On Bounds changing ");
    }
}
}
