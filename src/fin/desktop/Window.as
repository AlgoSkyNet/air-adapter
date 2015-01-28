/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {

import fin.desktop.connection.ResponseWaiter;
import fin.desktop.events.DesktopEventManager;
import fin.desktop.events.WindowEvent;
import fin.desktop.transitions.Transition;
import fin.desktop.transitions.TransitionOptions;

import flash.utils.Dictionary;

public class Window extends DesktopEventManager{

    private static var _instances: Dictionary = new Dictionary();

    private var _uuid: String;
    private var _name: String;

    public function Window(uuid: String, name: String) {

        super("window");
        _uuid = uuid;
        _name = name;

        _instances[_uuid + _name] = this;
        _defaultPayload = {uuid: uuid, name: name};

        WindowManager.initialise();
        //  sendMessage("register-child-window-settings", options, callback, errorCallback);

        //"{"action":"register-child-window-load-callback","payload":{"uuid":"OpenFinJSAPITestBench","name":"childWindow"},"messageId":2}"
        //{"action":"show-window","payload":{"uuid":"OpenFinJSAPITestBench","name":"childWindow"}}"
    }

    public static function createWindowUsingApplication(application: Application): Window {

        return new Window(application.uuid, application.name? application.name: application.uuid);
    }

    public static function getInstances(): Dictionary{

        return _instances;
    }

    public function animate(transition: Transition, options: TransitionOptions, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("animate-window", createPayload({options: options, transitions: transition}), callback, errorCallback);
    }

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

    public function hide(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("hide-windowe", createPayload(), callback, errorCallback);
    }

    public function bringToFront(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("bring-window-to-front", createPayload(), callback, errorCallback);
    }

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

    public function getState(callback: Function = null, errorCallback: Function = null): void{

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

    public function maximize(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("maximize-window", createPayload(), callback, errorCallback);
    }

    public function minimize(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("minimize-window", createPayload(), callback, errorCallback);
    }

    public function moveBy(deltaLeft: Number = 0, deltaTop: Number = 0, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("move-window-by", createPayload({deltaLeft: deltaLeft, deltaTop: deltaTop}), callback, errorCallback);
    }

    public function moveTo(left: Number = NaN, top: Number = NaN, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("move-window", createPayload({left: left, top: top}), callback, errorCallback);
    }

    public function resizeBy(deltaWidth: Number = 0, deltaHeight: Number = 0, anchor: String = "top-left",  callback: Function = null, errorCallback: Function = null): void{

        sendMessage("resize-window-by", createPayload({deltaWidth: deltaWidth, deltaHeight: deltaWidth, anchor: anchor}), callback, errorCallback);
    }

    public function resizeTo(width: Number = NaN, height: Number = NaN, anchor: String = "top-left",  callback: Function = null, errorCallback: Function = null): void{

        sendMessage("resize-window", createPayload({width: width, height: height, anchor: anchor}), callback, errorCallback);
    }

    public function restore(callback: Function = null, errorCallback: Function = null): void{

        sendMessage("restore-window", createPayload(), callback, errorCallback);
    }

    public function setBounds(left: Number, top: Number, width, height, callback: Function = null, errorCallback: Function = null): void{

        sendMessage("set-window-bounds", createPayload({left: left, top: top, width:width, height:height}), callback, errorCallback);
    }

}
}
