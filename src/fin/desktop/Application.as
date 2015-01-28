/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {
import fin.desktop.connection.ResponseWaiter;
import fin.desktop.events.DesktopEventManager;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class Application extends DesktopEventManager{

    private static var _instances: Dictionary = new Dictionary();

    private var _options: ApplicationOptions;
    private var _window: Window;

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

    public function run(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("run-application", createPayload(), callback, errorCallback);
    }

    public function terminate(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("terminate-application", createPayload(), callback, errorCallback);
    }

    public function close(force: Boolean = false, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("close-application", createPayload({force: force}), callback, errorCallback);
    }

    public function remove(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("remove-application", createPayload(), callback, errorCallback);
    }

    public function restart(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("restart-application", createPayload(), callback, errorCallback);
    }

    public function isRunning(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("is-application-running", createPayload(), callback, errorCallback);
    }

    public function setTrayIcon(enabledIcon: String, disabledIcon: String, hoverIcon: String, callback: Function = null, errorCallback: Function = null): void{

      //  {"action":"set-tray-icon","payload":{"uuid":"OpenFinJSAPITestBench","enabledIcon":"https://developer.openf.in/download/openfin.png","disabledIcon":"https://developer.openf.in/download/openfin.png","hoverIcon":"https://developer.openf.in/download/openfin.png"}}"
        sendMessage("set-tray-icon", createPayload({enabledIcon: enabledIcon, disabledIcon: disabledIcon, hoverIcon: hoverIcon}), callback, errorCallback);
    }

    public function removeTrayIcon(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("remove-tray-icon", createPayload(), callback, errorCallback);
    }

    public function wait(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("wait-for-hung-application", createPayload(), callback, errorCallback);
    }

    public function getManifest(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("get-application-manifest", createPayload(), callback, errorCallback);
    }

    public function getChildWindows(callback: Function , errorCallback: Function = null): void{

        var waiter: ResponseWaiter = new ResponseWaiter(onGetChildWindowsResponse, callback)
        sendMessage("get-child-windows", createPayload(), waiter.onResponse, errorCallback);
    }

    private function onGetChildWindowsResponse(callback: Function , data: Array): void{

        callback(getWindowsFromArray(data));
    }

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

    public function get window(): Window{

        return _window? _window: _window = Window.createWindowUsingApplication(this);
    }

    public static function wrap(uuid: String): Application{

        var options: ApplicationOptions = new ApplicationOptions(uuid);
        options._noRegister = true;
        return new Application(new ApplicationOptions(uuid))
    }
}
}
