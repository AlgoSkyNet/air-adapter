/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {

import com.openfin.OpenfinNativeExtention;

import fin.desktop.connection.ResponseWaiter;
import fin.desktop.events.DesktopEventManager;
import fin.desktop.events.WindowEvent;
import fin.desktop.transitions.Transition;
import fin.desktop.transitions.TransitionOptions;

import flash.utils.Dictionary;
/**
 *  A basic window that wraps a native HTML window.
 *  Provides more fine-grained control over the window state such as the ability to minimize, maximize, restore, etc.
 *  By default a window does not show upon instantiation; instead the window's show() method must be invoked manually.
 *  The new window appears in the same process as the parent window.
 */
public class Window extends DesktopEventManager{

    private static var _instances: Dictionary = new Dictionary();
    private static var ane: OpenfinNativeExtention;

    public var _uuid: String;
    public var _name: String;

    /**
     * Window constructor
     *
     * @param uuid UUID of the parent Application
     * @param name Name of the Window
     *
     */
    public function Window(uuid: String, name: String) {

        super("window");
        _uuid = uuid;
        _name = name;

        _instances[_uuid + name] = this;
        _defaultPayload = {uuid: uuid, name: name};

        WindowManager.initialise();
        //  sendMessage("register-child-window-settings", options, callback, errorCallback);

        //"{"action":"register-child-window-load-callback","payload":{"uuid":"OpenFinJSAPITestBench","_name":"childWindow"},"messageId":2}"
        //{"action":"show-window","payload":{"uuid":"OpenFinJSAPITestBench","_name":"childWindow"}}"
    }

    public static function createWindowUsingApplication(application: Application): Window {

        return new Window(application.uuid, application.name? application.name: application.uuid);
    }

    public static function registerExternalWindow(uuid: String, name: String, callback: Function = null, errorCallback: Function = null): Window{

        if(!ane)ane = new OpenfinNativeExtention();
        sendMessage("register-external-window", {topic: "application", hwnd: ane.getHWND() , uuid:uuid, name: name}, callback, errorCallback);
        return new Window(uuid, name);
    }

    public static function getInstances(): Dictionary{

        return _instances;
    }

    public function animate(transition: Transition, options: TransitionOptions, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("animate-window", createPayload({options: options, transitions: transition}), callback, errorCallback);
    }

    /**
     * Shows the window if it is hidden
     *
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function show(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("show-window", createPayload(), callback, errorCallback);
    }

    public function showAt(left: Number, top: Number, toggle: Boolean = false, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("show-at-window", createPayload({left: left, top: top, toggle: toggle}), callback, errorCallback);
    }

    public function flash(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("flash-window", createPayload(), callback, errorCallback);
    }

    public function blur(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("blur-window", createPayload(), callback, errorCallback);
    }

    public function focus(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("focus-window", createPayload(), callback, errorCallback);
    }

    public function enableFrame(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("enable-window-frame", createPayload(), callback, errorCallback);
    }

    public function disableFrame(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("disable-window-frame", createPayload(), callback, errorCallback);
    }


    /**
     * Hides the window if it is shown
     *
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     *
     */
    public function hide(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("hide-windowe", createPayload(), callback, errorCallback);
    }

    public function bringToFront(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("bring-window-to-front", createPayload(), callback, errorCallback);
    }

    /**
     * Closes the window
     *
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function close(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("close-window", createPayload(), callback, errorCallback);
    }

    public function getBounds(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("get-window-bounds", createPayload(), callback, errorCallback);
    }

    public function getGroup(callback: Function = null, errorCallback: Function = null): void{

        var waiter: ResponseWaiter = new ResponseWaiter(onGetGroupResponse, callback);
        sendMessage("get-window-group", createPayload(), waiter.onResponse, errorCallback);
    }
    private function onGetGroupResponse(callback: Function, data: Array): void{

        var length: int = data.length;
        if(length <= 0) callback(null);

        var windows: Vector.<Window> = new Vector.<Window>();

        for(var i: int = 0; i < length; i++ ){

            windows.push(new Window(data[i].uuid, data[i].name));
        }

        callback(windows);
    }

    public function getOptions(callback: Function = null, errorCallback: Function = null): void{

        var waiter: ResponseWaiter = new ResponseWaiter(onGetOptionsResponse, callback);
        sendMessage("get-window-options", createPayload(), waiter.onResponse, errorCallback);
    }

    private function onGetOptionsResponse(callback: Function, data: Object): void{

        var options: WindowOptions = new WindowOptions();
        for(var i: String in data){

            options[i] = data[i];
        }

        callback(options);
    }

    public function updateOptions(options: WindowOptions, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("update-window-options", createPayload({options: options}), callback, errorCallback);
    }

    public function getSnapshot(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("get-window-snapshot", createPayload(), callback, errorCallback);
    }

    /**
     * Gets the current state ("minimized", "maximized", or "restored") of the window
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function getState(callback: Function, errorCallback: Function = null): void{

        sendMessage("get-window-state", createPayload(), callback, errorCallback);
    }

    public function isShowing(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("is-window-showing", createPayload(), callback, errorCallback);
    }

    public function joinGroup(window: Window, callback: Function = null, errorCallback: Function = null): void{


        sendMessage("join-window-group", createPayload({groupingWindowName: window._name}), callback, errorCallback);
    }

    public function mergeGroup(window: Window, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("merge-window-group", createPayload({groupingWindowName: window._name}), callback, errorCallback);
    }

    public function leaveGroup(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("leave-window-group", createPayload(), callback, errorCallback);
    }

    /**
     * Maximizes the window
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function maximize(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("maximize-window", createPayload(), callback, errorCallback);
    }

    /**
     * Minimizes the window
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function minimize(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("minimize-window", createPayload(), callback, errorCallback);
    }

    /**
     * Moves the window by a specified amount
     *
     * @param deltaLeft The change in the left position of the window
     * @param deltaTop The change in the top position of the window
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function moveBy(deltaLeft: Number = 0, deltaTop: Number = 0, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("move-window-by", createPayload({deltaLeft: deltaLeft, deltaTop: deltaTop}), callback, errorCallback);
    }

    /**
     * Moves the window to a specified location
     *
     * @param left The left position of the window
     * @param top The right position of the window
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function moveTo(left: Number = NaN, top: Number = NaN, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("move-window", createPayload({left: left, top: top}), callback, errorCallback);
    }

    /**
     * Resizes the window by the specified amount
     *
     * @param deltaWidth Width delta of the window
     * @param deltaHeight Height delta of the window
     * @param anchor Specifies a corner to remain fixed during the resize.  Please check resizeTo method for more information
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     *
     * @see resizeTo
     */
    public function resizeBy(deltaWidth: Number = 0, deltaHeight: Number = 0, anchor: String = "top-left",  callback: Function = null, errorCallback: Function = null): void{

        sendMessage("resize-window-by", createPayload({deltaWidth: deltaWidth, deltaHeight: deltaWidth, anchor: anchor}), callback, errorCallback);
    }

    /**
     * Resizes the window to the specified dimensions
     *
     * @param width Width of the window
     * @param height Height of the window
     * @param anchor Specifies a corner to remain fixed during the resize.
     *               Can take the values:
     *                      "top-left"
     *                      "top-right"
     *                      "bottom-left"
     *                      "bottom-right"
     *               default is "top-left".
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function resizeTo(width: Number = NaN, height: Number = NaN, anchor: String = "top-left",  callback: Function = null, errorCallback: Function = null): void{

        sendMessage("resize-window", createPayload({width: width, height: height, anchor: anchor}), callback, errorCallback);
    }

    public function restore(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("restore-window", createPayload(), callback, errorCallback);
    }

    public function setBounds(left: Number, top: Number, width, height, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("set-window-bounds", createPayload({left: left, top: top, width:width, height:height}), callback, errorCallback);
    }

    /**
     * Gets HWND of the current window
     *
     * @param callback A function that is called if the method succeeds.
     * @param errorCallback A function that is called when method fails.
     */
    public function  getNativeId(callback: Function = null, errorCallback: Function = null): void {

        sendMessage("get-window-native-id", createPayload({uuid: _uuid, name: _name}), callback, errorCallback);
    }


}
}
