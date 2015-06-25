/**
 * Created by haseebriaz on 23/01/2015.
 */
package tests {

import fin.desktop.Application;
import fin.desktop.ApplicationOptions;
import fin.desktop.Window;
import fin.desktop.WindowOptions;
import fin.desktop.events.ApplicationEvent;
import fin.desktop.events.WindowEvent;

public class ApplicationTest {

    public function ApplicationTest() {

        var applicationOptions: ApplicationOptions = new ApplicationOptions("child","http://www.google.com");
        var windowOptions: WindowOptions = new WindowOptions();
        windowOptions.minimizable = true;
        windowOptions.maximizable = true;
        windowOptions.autoShow = true;
        windowOptions.showTaskbarIcon = true;
        windowOptions.frame = true;

        var app: Application = new Application(applicationOptions, function(value){
            trace("app created");
            showWindow(app);
            app.run();
        }, function(reason: String){




            showWindow(app);
        });
    }

    private function onAppStarted(event: ApplicationEvent): void{

        trace("application started", event.target);
        var app: Application = event.application;
        app.window.show();
        app.getGroups(function(groups){

        });
        app.addEventListener(ApplicationEvent.TRAY_ICON_CLICKED, function(event: ApplicationEvent){

            trace("icon was clicked", event.payload.x, event.payload.y);
            event.application.removeTrayIcon();
        });
    }

    private function showWindow(app: Application): void{

        trace("window");
        app.addEventListener(ApplicationEvent.STARTED, onAppStarted);
        app.addEventListener(ApplicationEvent.CLOSED, function(event: ApplicationEvent){

            trace("application closed");
        });
        app.run();

        var window: Window = app.window;
        window.show();
        window.addEventListener(WindowEvent.BOUNDS_CHANGED, onBoundsChanged);
        window.addEventListener(WindowEvent.BOUNDS_CHANGING, onBoundsChanging);
        window.addEventListener(WindowEvent.BLURRED, onBlurr);
        window.moveTo(0, 0);


    }

    private function onBoundsChanged(event: WindowEvent): void{

        var payload: Object = event.payload;
        trace("bounds changed!", payload.left, payload.top, payload.width, payload.height);
    }

    private function onBoundsChanging(event: WindowEvent): void{

        var payload: Object = event.payload;
        trace("bounds changing", payload.left, payload.top, payload.width, payload.height);
    }

    private function onBlurr(event: WindowEvent): void{

        trace("window blurred!");

    }
}
}
