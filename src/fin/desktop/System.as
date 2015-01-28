/**
 * Created by haseebriaz on 19/01/2015.
 */
package fin.desktop {
import fin.desktop.connection.DesktopConnection;
import fin.desktop.connection.DesktopConnectionEvent;
import fin.desktop.connection.ResponseWaiter;
import fin.desktop.events.EventManager;

public class System {

    private var _eventManager: EventManager;
    private var _connection: DesktopConnection;
    private static var _instance: System;

    public static function getInstance(): System{

        return _instance? _instance: _instance = new System();
    }

    public function System() {

        if(_instance) throw new Error("Only one instance of System is allowed");

        _eventManager = new EventManager();
        _connection = DesktopConnection.getInstance();
        _connection.addEventListener(DesktopConnectionEvent.PROCESS_DESKTOP_EVENT, processDesktopEvent);
        _instance = this;
    }

    private function processDesktopEvent(event: DesktopConnectionEvent): void{

        _eventManager.dispatchEvent(event.payload.topic + event.payload.type, event.payload);
    }

    private function sendMessage(action: String, payload: Object, callback: Function, errorCallback: Function = null): void{

        _connection.sendMessage(action, payload, callback, errorCallback);
    }

    public function getVersion(callBack: Function, errorCallback: Function = null): void{

        sendMessage("get-version", null, callBack, errorCallback);
    }

    public function getDeviceId(callBack: Function, errorCallback: Function = null): void{

        sendMessage("get-device-id", null, callBack, errorCallback);
    }

    public function getProcessList(callBack: Function, errorCallback: Function = null): void{

        sendMessage("process-snapshot", null, callBack, errorCallback);
    }

    public function getLogList(callBack: Function, errorCallback: Function = null): void{

       sendMessage("list-logs", null, callBack, errorCallback);
    }

    public function getAllApplications(callBack: Function, errorCallback: Function = null): void{

        sendMessage("get-all-applications", null, callBack, errorCallback);
    }

    public function getAllWindows(callBack: Function, errorCallback: Function = null): void{

        sendMessage("get-all-windows", null, callBack, errorCallback);
    }

    public function getMousePosition(callBack: Function, errorCallback: Function = null): void{

        sendMessage("get-mouse-position", null, callBack, errorCallback);
    }

    public function clearCache(options: Object, callback: Function, errorCallback: Function = null): void{

        sendMessage("clear-cache", options, callback, errorCallback);
    }

    public function deleteCacheOnRestart(callback: Function, errorCallback: Function = null): void{

        sendMessage("delete-cache-request", null, callback, errorCallback);
    }

    public function exit(callback: Function, errorCallback: Function = null):void {

        sendMessage("exit-desktop", null, callback, errorCallback);
    }

    public function getCommandLineArguments(callback: Function, errorCallback: Function = null): void{

        sendMessage("get-command-line-arguments", null, callback, errorCallback);
    }

    public function getLog(options: Object, callback: Function, errorCallback: Function = null): void{

        sendMessage("view-log", options, callback, errorCallback);
    }

    public function getMonitorInfo(callback: Function, errorCallback: Function = null): void{

        sendMessage("get-monitor-info", null, callback, errorCallback);
    }

    public function launchExternalProcess(path: String, commandLine: String, callback: Function, errorCallback: Function = null): void{

        sendMessage("launch-external-process", {path: path, commandLine: commandLine}, callback, errorCallback);
    }

    public function log(level: String, message: String, callback: Function, errorCallback: Function = null): void{

        sendMessage("write-to-log", {level: level, message: message}, callback, errorCallback);
    }

    public function addEventListener(type: String, listener: Function, callback: Function, errorCallback: Function = null): void {

        var payload:Object = {"topic": "system", "type": type};

        //if already subscribed to event type, just add the handler
        if(_eventManager.hasEventListener(payload.topic + payload.type)){

            _eventManager.addEventListener(payload.topic + payload.type, listener);
            callback();
            return;
        }

        var waiter: ResponseWaiter = new ResponseWaiter(_onAddEventListenerResponse, payload.topic + payload.type, listener, callback)
        sendMessage("subscribe-to-desktop-event", payload, waiter.onResponse, errorCallback);
    }

    private function _onAddEventListenerResponse(type: String, listener: Function, callback: Function): void{

        _eventManager.addEventListener(type, listener);
        callback;
    }

    public function removeEventListener(type: String, listener: Function, callback: Function, errorCallback: Function = null ): void{

        //if there are other listeners registered for the type, do not un-subscribe
        if(_eventManager.removeEventListener("system" + type, listener) > 0) {

            callback();
            return;
        }

        var payload:Object = {"topic": "system", "type": type};
        sendMessage("unsubscribe-to-desktop-event", payload, callback, errorCallback);
    }
}

}
