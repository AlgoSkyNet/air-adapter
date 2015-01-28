/**
 * Created by haseebriaz on 27/01/2015.
 */
package fin.desktop.events {
import fin.desktop.Application;

import flash.events.Event;

public class ApplicationEvent extends Event{

    public static const CLOSED: String = "closed";
    public static const CRASHED: String = "crashed";
    public static const ERROR: String = "error";
    public static const NOT_RESPONDING: String = "not-responding";
    public static const OUT_OF_MEMORY: String = "out-of-memory";
    public static const RESPONDING: String = "responding";
    public static const RUN_REQUESTED: String = "run-requested";
    public static const STARTED: String = "started";
    public static const TRAY_ICON_CLICKED: String = "tray-icon-clicked";

    private var _payload: Object;
    private var _application: Application;

    public function ApplicationEvent(type: String, payload: Object, application: Application) {

        _payload = payload;
        _application = application;

        super(type);
    }

    public function get payload():Object {
        return _payload;
    }

    public function get application():Application {
        return _application;
    }
}
}
