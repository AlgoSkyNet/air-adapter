/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {
import fin.desktop.connection.ResponseWaiter;
import fin.desktop.events.DesktopEventManager;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

/**
 * An object representing the Application.
 * Allows the developer to execute, show and close an application,
 * as well as show and hide an icon on Desktop. Also provides access
 * to the Window object for the main application window to control
 * window state such as the ability to minimize, maximize, restore, etc.
 */
public class Application extends DesktopEventManager{

    private static var _instances: Dictionary = new Dictionary();

    private var _options: ApplicationOptions;
    private var _window: Window;

    /**
     * Application Constructor
     * @param options Settings of the application
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     *
     * @see ApplicationOptions
     * @see fin.desktop.events.DesktopEventManager
     *
     * @event CLOSED fin.desktop.events.ApplicationEvent [dispatched when application has closed]
     * @event CRASHED fin.desktop.events.ApplicationEvent [dispatched when application has crashed]
     * @event ERROR fin.desktop.events.ApplicationEvent [dispatched when there is an error]
     * @event NOT_RESPONDING fin.desktop.events.ApplicationEvent [dispatched when  when application is not responding]
     * @event RESPONDING fin.desktop.events.ApplicationEvent [dispatched when application is responding again]
     * @event RUN_REQUESTED fin.desktop.events.ApplicationEvent [dispatched when there is a for running the application]
     * @event STARTED fin.desktop.events.ApplicationEvent [dispatched when application has started]
     * @event TRAY_ICON_CLICKED fin.desktop.events.ApplicationEvent [dispatched when the tray icon has been clicked]
     *
     */
    public function Application(options: ApplicationOptions, callback: Function = null, errorCallback: Function = null) {

        super("application");
        _options = options;
        _eventDispatcher = new EventDispatcher();
        _defaultPayload = {uuid: uuid};

        _instances[uuid] = this;
        ApplicationManager.initialise();

        if(_options._noRegister) return;
        sendMessage("create-application", options, callback, errorCallback);
    }


    public static function getInstances(): Dictionary{

        return _instances;
    }

    /**
     *  Runs the application
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function run(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("run-application", createPayload(), callback, errorCallback);
    }

    /**
     * Closes the application by terminating its process.
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function terminate(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("terminate-application", createPayload(), callback, errorCallback);
    }

    /**
     * Closes the application and any child windows created by the application
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function close(force: Boolean = false, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("close-application", createPayload({force: force}), callback, errorCallback);
    }

    /**
     * Restarts the application
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function restart(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("restart-application", createPayload(), callback, errorCallback);
    }

    /**
     * A test for if application is runngin or not.
     * @param callback A function that gets a boolean value passed to indicating if application is running or not.
     * @param errorCallback A function that is called when method fails.
     */
    public function isRunning(callback: Function, errorCallback: Function = null): void{

        sendMessage("is-application-running", createPayload(), callback, errorCallback);
    }

    /**
     * Sets a tray icon for the application
     * @param enabledIcon URL to the image that gets used as enabled tray icon
     * @param disabledIcon URL to the image that gets used as disabled tray icon
     * @param hoverIcon URL to the image that gets used as hover(mouse over) tray icon
     * @param callback A function that will be called if successful.
     * @param errorCallback A function that is called on failure.
     */
    public function setTrayIcon(enabledIcon: String, disabledIcon: String, hoverIcon: String, callback: Function = null, errorCallback: Function = null): void{

      //  {"action":"set-tray-icon","payload":{"uuid":"OpenFinJSAPITestBench","enabledIcon":"https://developer.openf.in/download/openfin.png","disabledIcon":"https://developer.openf.in/download/openfin.png","hoverIcon":"https://developer.openf.in/download/openfin.png"}}"
        sendMessage("set-tray-icon", createPayload({enabledIcon: enabledIcon, disabledIcon: disabledIcon, hoverIcon: hoverIcon}), callback, errorCallback);
    }

    /**
     * Removes the icon from the tray if there is one.
     * @param callback A function that will be called if successful.
     * @param errorCallback A function that is called on failure.
     */
    public function removeTrayIcon(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("remove-tray-icon", createPayload(), callback, errorCallback);
    }

    /**
     * Waits for a hanging application. This method can be called in response to an application "not-responding" to allow the application
     * to continue and to generate another "not-responding" message after a certain period of time.
     *
     */
    public function wait(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("wait-for-hung-application", createPayload(), callback, errorCallback);
    }

    /**
     *
     * Retrieves the JSON manifest that was used to create the application.
     * Invokes the error callback if the application was not created from a manifest.
     * callback is called and passed an Object containing the JSONObject manifest
     * that was used to create the application.
     *
     * @param callback A function that will be called if successful.
     * @param errorCallback A function that is called on failure.
     */
    public function getManifest(callback: Function, errorCallback: Function = null): void{

        sendMessage("get-application-manifest", createPayload(), callback, errorCallback);
    }

    /**
     *
     * Retrieves an array of wrapped fin.desktop.Windows for each of the application’s child windows.
     *
     * @param callback A function that will be called if successful, and a Vector of fin.desktop.Window will be passed.
     * @param errorCallback A function that is called on failure.
     */
    public function getChildWindows(callback: Function , errorCallback: Function = null): void{

        var waiter: ResponseWaiter = new ResponseWaiter(onGetChildWindowsResponse, callback)
        sendMessage("get-child-windows", createPayload(), waiter.onResponse, errorCallback);
    }

    private function onGetChildWindowsResponse(callback: Function , data: Array): void{

        callback(getWindowsFromArray(data));
    }

    /**
     *
     * Retrieves an array of active window groups for all of the application's windows. Each group is represented as an Vector of wrapped fin.desktop.Window
     *
     * @param callback A function that will be called if successful, and nested Vector(Vector of fin.desktop.Window Vectors) will be passed.
     * @param errorCallback A function that is called on failure.
     */
    public function getGroups(callback: Function , errorCallback: Function = null): void{

        var waiter: ResponseWaiter = new ResponseWaiter(onGetGroupsCallback, callback)
        sendMessage("get-application-groups", createPayload(), waiter.onResponse, errorCallback);
    }

    public function onGetGroupsCallback(callback: Function, data: Array): void{

        var length: int = data.length;
        if(!length) callback(null);

        var groups: Vector.<Vector.<Window>> = new Vector.<Vector.<Window>>();
        for(var i: int = 0; i < length; i++){

            groups.push(getWindowsFromArray(data[i]));
        }
        callback(groups);
    }

    private function getWindowsFromArray(data: Array): Vector.<Window>{

        var length: int = data.length;
        if(length <= 0) return null;

        var windows: Vector.<Window> = new Vector.<Window>();

        for(var i: int = 0; i < length; i++ ){

            windows.push(new Window(data[i].uuid, data[i].name));
        }

        return windows;
    }

    public function get uuid(): String{

        return _options.uuid;
    }

    public function get name(): String{

        return _options.name;
    }

    public function get url(): String{

        return _options.url;
    }

    /**
     * an instance of the main Window of the application.
     * @see fin.desktop.Window
     */
    public function get window(): Window{

        return _window? _window: _window = Window.createWindowUsingApplication(this);
    }

    /**
     * Attaches an Application object to an application that already exists
     * @param uuid The UUID of the Application to wrap
     * @return Application
     */
    public static function wrap(uuid: String): Application{

        var options: ApplicationOptions = new ApplicationOptions(uuid);
        options._noRegister = true;
        return new Application(new ApplicationOptions(uuid))
    }

}
}
