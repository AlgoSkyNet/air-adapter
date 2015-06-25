/**
 * Created by haseebriaz on 22/06/2015.
 */
package fin.desktop {
import com.openfin.OpenfinNativeExtention;

import fin.desktop.events.WindowEvent;

import flash.display.NativeWindow;

import flash.display.NativeWindow;
import flash.events.Event;
import flash.events.NativeWindowBoundsEvent;

public class ExternalWindow extends Window{

    private var ane: OpenfinNativeExtention;
    private var _nativeWindow: NativeWindow;
    private var callBack: Function;
    private var hwnd: String;
    public function ExternalWindow(nativeWindow: NativeWindow, uuid: String, name: String, callback: Function = null, errorCallback: Function = null) {

        super (uuid, name);
        this.callBack = callback;
        _nativeWindow = nativeWindow;
        if(!ane)ane = new OpenfinNativeExtention();
        hwnd = ane.getHWND();
        sendMessage("register-external-window", {topic: "application", hwnd: hwnd , uuid:uuid, name: name}, onRegister, errorCallback);
        addEventListener(WindowEvent.FRAME_DISABLED, this._onFrameDisabled);
        addEventListener(WindowEvent.FRAME_ENABLED, this._onFrameEnabled);
        addEnabledFrameListeners();
    }


    private function onRegister(message): void{

        trace(message);
    }

    private function _onFrameDisabled(event: WindowEvent): void{

        addDisabledFrameListeners();
    }

    private function _onFrameEnabled(event: WindowEvent): void{

        addEnabledFrameListeners();
    }

    private function addDisabledFrameListeners(): void{

        _nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVING, _onDisabledFrameMove);
        _nativeWindow.removeEventListener(NativeWindowBoundsEvent.MOVING, _onEnabledFrameMove);
    }

    private function addEnabledFrameListeners(): void{

        _nativeWindow.removeEventListener(NativeWindowBoundsEvent.MOVING, _onDisabledFrameMove);
        _nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVING, _onEnabledFrameMove);
        _nativeWindow.addEventListener(Event.ACTIVATE, onActivateChanged);
        _nativeWindow.addEventListener(Event.DEACTIVATE, onActivateChanged);
    }

    private function _onDisabledFrameMove(event: NativeWindowBoundsEvent): void{

        event.preventDefault();
    }

    private function _onEnabledFrameMove(event: NativeWindowBoundsEvent): void{

        sendWindowMoveEvent(event.afterBounds.x, event.afterBounds.y, 10, 10);
    }

    private function sendWindowMoveEvent(x: int, y: int, right: int, bottom: int): void{

        sendMessage("external-window-action", {type: 0x0216 ,hwnd: hwnd,  uuid:_uuid, name: _name,x: x, y: y, right: x + 200, bottom: y + 200});
        // var bounds: Object = {left: x, top: y, rigth: right, bottom: bottom };
        //sendMessage("external-window-action", {type: "WM_MOVE" , uuid:_uuid, name: _name,bounds: bounds});
        //sendMessage("external-window-action", {type: 0x0046 , uuid:_uuid, name: _name,bounds: bounds});
        sendMessage("external-window-action", {type: 0x0046 ,hwnd: hwnd,  uuid:_uuid, name: _name,x: x, y: y, cx: 10, cy:10});
    }

    private function onActivateChanged(event: Event): void{

        if(event.type == Event.ACTIVATE)
            sendMessage("external-window-action", {type: 0x0007 , uuid:_uuid, name: _name});
        else
            sendMessage("external-window-action", {type: 0x0008 , uuid:_uuid, name: _name});
    }
}
}
