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

        var app: Application = new Application(new ApplicationOptions("cpuTest2", "cpuTest2", "http://www.google.com"), function(value){

            showWindow(app);
        }, function(reason: String){

            showWindow(app);
        });
    }

    private function onAppStarted(event: ApplicationEvent): void{

        trace("application started", event.target);
        var app: Application = event.application;
        app.getGroups(function(groups){

        })
        app.addEventListener(ApplicationEvent.TRAY_ICON_CLICKED, function(event: ApplicationEvent){

            trace("icon was clicked", event.payload.x, event.payload.y);
            event.application.removeTrayIcon();
        });

        app.setTrayIcon("https://developer.openf.in/download/openfin.png","https://developer.openf.in/download/openfin.png", "https://developer.openf.in/download/openfin.png", function(){

            trace("application restarted");
        }, function(reason: String){

            trace("could not set icon", reason);
        });
    }

    private function showWindow(app: Application): void{

        app.addEventListener(ApplicationEvent.STARTED, onAppStarted);
        app.addEventListener(ApplicationEvent.CLOSED, function(event: ApplicationEvent){

            trace("application closed");
        });
        app.run();

        var window: Window = app.window;
        window.addEventListener(WindowEvent.BOUNDS_CHANGED, onBoundsChanged);
        window.addEventListener(WindowEvent.BOUNDS_CHANGING, onBoundsChanging);
        window.addEventListener(WindowEvent.BLURRED, onBlurr);
        window.moveTo(0, 0);

        var options: WindowOptions = new WindowOptions();
        options.opacity = 1;
        options.frame = true;
        options.minimizable = true;
        options.maximizable = true;
        options.draggable = true;
        window.updateOptions(options, function(){

        });
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
