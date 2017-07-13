/**
 * Created by haseebriaz on 19/01/2015.
 */
package fin.desktop {
import fin.desktop.connection.DesktopConnection;
import fin.desktop.connection.DesktopConnectionEvent;
import fin.desktop.connection.ResponseWaiter;
import fin.desktop.events.EventManager;
import fin.desktop.logging.ILogger;
import fin.desktop.logging.LoggerFactory;

import flash.utils.getQualifiedClassName;

/**
 * @class System
 */
public class System {

    private var _eventManager: EventManager;
    private var _connection: DesktopConnection;
    private static var _instance: System;
    private var _logger:ILogger;

    /**
     * Gets and instance of the System
     */
    public static function getInstance(): System{
        if (_instance) {
            if (!_instance._connection.valid) {
                _instance.initConnection();
            }
        } else {
            _instance = new System();
        }
        return _instance;
    }

    public function System() {

        if(_instance) throw new Error("Only one instance of System is allowed");

        _logger = LoggerFactory.getLogger(getQualifiedClassName(System));
        _eventManager = new EventManager();
        initConnection();
        _instance = this;
    }

    private function initConnection():void {
        _logger.debug("initConnection");
        _connection = DesktopConnection.getInstance();
        _connection.addEventListener(DesktopConnectionEvent.PROCESS_DESKTOP_EVENT, processDesktopEvent);
    }

    private function processDesktopEvent(event: DesktopConnectionEvent): void{

        _eventManager.dispatchEvent(event.payload.topic + event.payload.type, event.payload);
    }

    private function sendMessage(action: String, payload: Object, callback: Function, errorCallback: Function = null): void{

        _connection.sendMessage(action, payload, callback, errorCallback);
    }

    /**
     * Gets AppDesktop version number
     * @param callback A function that is called if successful, with version number passed to it.
     * @param errorCallback A function that is called if the method fails
     */
    public function getVersion(callBack: Function, errorCallback: Function = null): void{

        sendMessage("get-version", null, callBack, errorCallback);
    }

    /**
     * Gets Device ID
     * @param callback A function that is called if successful with device id passed to it.
     * @param errorCallback A function that is called if the method fails
     */
    public function getDeviceId(callBack: Function, errorCallback: Function = null): void{

        sendMessage("get-device-id", null, callBack, errorCallback);
    }

    /**
     * Retrieves an array of all processes that are currently running
     * Each element in the array is an object containing the uuid
     * and the _name of the application to which the process belongs.
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function getProcessList(callBack: Function, errorCallback: Function = null): void{

        sendMessage("process-snapshot", null, callBack, errorCallback);
    }

    /**
     * Retrieves an array of data objects for all available logs
     * Each object in the returned array takes the form:
     *   {
     *       _name: (string) the filename of the log,
     *       size: (integer) the size of the log in bytes,
     *       date: (integer) the unix time at which the log was created
     *    }
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function getLogList(callBack: Function, errorCallback: Function = null): void{

       sendMessage("list-logs", null, callBack, errorCallback);
    }

    /**
     * Retrieves an array of data (uuid, running/active state) for all application windows
     *     The object passed to callback takes the form:
     *     [
     *         {
     *             uuid: (string) uuid of the application,
     *             isRunning: (bool) true when the application is running/active
     *         },
     *         ...
     *     ]
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function getAllApplications(callBack: Function, errorCallback: Function = null): void{

        sendMessage("get-all-applications", null, callBack, errorCallback);
    }

    /**
     *     The object passed to callback takes the form:
     *     [
     *         {
     *             uuid: (string) uuid of the application,
     *             mainWindow: {
     *                 _name: (string) _name of the main window,
     *                 top: (integer) top-most coordinate of the main window,
     *                 right: (integer) right-most coordinate of the main window,
     *                 bottom: (integer) bottom-most coordinate of the main window,
     *                 left: (integer) left-most coordinate of the main window
     *             },
     *             childWindows: [{
     *                     _name: (string) _name of the child window,
     *                     top: (integer) top-most coordinate of the child window,
     *                     right: (integer) right-most coordinate of the child window,
     *                     bottom: (integer) bottom-most coordinate of the child window,
     *                     left: (integer) left-most coordinate of the child window
     *                 },
     *                 ...
     *             ]
     *         },
     *         ...
     *     ]
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function getAllWindows(callBack: Function, errorCallback: Function = null): void{

        sendMessage("get-all-windows", null, callBack, errorCallback);
    }

    /**
     * Returns the mouse in virtual screen coordinates (left, top)
     *     The returned object takes the form:
     *     {
     *         top: (integer) the top position of the mouse in virtual screen
     *                        coordinates,
     *         left: (integer) the left position of the mouse in virtual screen
     *                         coordinates
     *     }
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function getMousePosition(callBack: Function, errorCallback: Function = null): void{

        sendMessage("get-mouse-position", null, callBack, errorCallback);
    }

    /**
     *  Clears cached data containing window state/positions,
     *  application resource files (images, HTML, JavaScript files)
     *  cookies, and items stored in the Local Storage.
     *
     * @param cache If true, clears chrome caches
     * @param cookies If true, deletes all cookies
     * @param localStorage If true, clear application caches
     * @param appcache If true, clears local storage
     * @param userData If true, clears user data
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     *
     */
    public function clearCache(cashe: Boolean = false, cookies: Boolean = false, localStorage: Boolean = false, appCache: Boolean = false, userData: Boolean = false, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("clear-cache", {cashe: cashe, cookies: cookies, localStorage: localStorage, appcache: appCache, userData: userData}, callback, errorCallback);
    }

    /**
     * Clears all cached data when App Desktop is restarted
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function deleteCacheOnRestart(callback: Function, errorCallback: Function = null): void{

        sendMessage("delete-cache-request", null, callback, errorCallback);
    }

    /**
     * Exits App Desktop
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function exit(callback: Function, errorCallback: Function = null):void {

        sendMessage("exit-desktop", null, callback, errorCallback);
    }

    /**
     * Retrieves the command line argument string that started the App
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function getCommandLineArguments(callback: Function, errorCallback: Function = null): void{

        sendMessage("get-command-line-arguments", null, callback, errorCallback);
    }

    /**
     * Retrieves the contents of the log with the specified filenamener
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function getLog(options: Object, callback: Function, errorCallback: Function = null): void{

        sendMessage("view-log", options, callback, errorCallback);
    }

    public function getMonitorInfo(callback: Function, errorCallback: Function = null): void{

        sendMessage("get-monitor-info", null, callback, errorCallback);
    }

    /**
     *
     * Runs an executable or batch file.
     *
     * @param path The path of the file to launch via the command line
     * @param commandLine The command line arguments to pass
     * @param callback A function that is called if the method succeeds
     * @param errorCallback A function that is called if the method fails
     */
    public function launchExternalProcess(path: String, commandLine: String, callback: Function, errorCallback: Function = null): void{

        sendMessage("launch-external-process", {path: path, commandLine: commandLine}, callback, errorCallback);
    }

    /**
     *
     * Attempts to cleanly close an external process and terminates it
     * if the close has not occured after the elapsed timeout in milliseconds.
     *
     * @param processUuid The UUID for a process launched by DesktopSystem.launchExternalProcess()
     * @param timeout The time in milliseconds to wait for a close to occur before terminating
     * @param killTree
     * @param callback A function that is called if the method succeed with result code being passed
     * @param errorCallback A function that is called if the method fails
     */
    public function terminateExternalProcess(processUuid: String, timeout: int, killTree: Boolean, callback: Function, errorCallback: Function = null): void{

        sendMessage("terminate-external-process", {uuid: processUuid, timeout: timeout, child: killTree }, callback, errorCallback);
    }

    /**
     *
     * Removes the process entry for the passed UUID
     *
     * @param processUuid The UUID for a process
     * @param callback function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function releaseExternalProcess(processUuid: String, callback: Function, errorCallback: Function = null): void{

        sendMessage("release-external-process", {uuid: processUuid}, callback, errorCallback);
    }

    /**
     * Writes a message to the log
     * @param level The log level for the entry. Can be either "info", "warning" or "error"
     * @param message The log message text
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function log(level: String, message: String, callback: Function, errorCallback: Function = null): void{

        sendMessage("write-to-log", {level: level, message: message}, callback, errorCallback);
    }

    /**
     * Opens the passed URL
     */
    public function openUrlWithBrowser(url: String, callback: Function, errorCallback: Function = null): void{

        sendMessage("open-url-with-browser", {url: url}, callback, errorCallback);
    }

    /**
     * Stores a cookie in the runtime
     *
     * @param url The URL that the cookie is for
     * @param name The key used to lookup the value
     * @param value The value paired with the key (_name)
     * @param ttl The time to till the cookie expires in milliseconds.  Never expires when set to 0.  Defaults to 0.
     * @param secure Accessible only on a secured connection (SSL)
     * @param httpOnly Accessible only on HTTP/HTTPS.
     * @param callback A function that is called if successful
     * @param errorCallback A function that is called if the method fails
     */
    public function setCookie(url: String, name: String, value: String, ttl: Number, secure: Boolean, httpOnly: Boolean, callback: Function, errorCallback: Function = null): void{

        sendMessage("set-cookie", {url: url, name: name, value: value, ttl: ttl, secure: secure, httpOnly: httpOnly}, callback, errorCallback);
    }

    /**
     * Registers an event listener on the specified event
     * @param type Type of the event
     * @param listener The listener function for the event
     * @param callback A function that is called if successful in registering the event
     * @param errorCallback A function that is called if the method fails
     * @see fin.desktop.events.SystemEvent
     * @see removeEventListener()
     */
    public function addEventListener(type: String, listener: Function, callback: Function = null, errorCallback: Function = null): void {

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
        callback();
    }

    /**
     * Removes a previously registered event listener from the specified event
     * @param type Type of the event
     * @param listener The listener function for the event
     * @param callback A function that is called if successful in un-registering the event
     * @param errorCallback A function that is called if the method fails
     *
     * @see fin.desktop.events.SystemEvent
     */
    public function removeEventListener(type: String, listener: Function, callback: Function = null, errorCallback: Function = null ): void{

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
