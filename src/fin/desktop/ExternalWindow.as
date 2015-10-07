/**
 * Created by haseebriaz on 22/06/2015.
 */
package fin.desktop {
import com.openfin.OpenfinNativeExtention;
import fin.desktop.events.WindowEvent;
import flash.display.NativeWindow;
import flash.events.Event;
import flash.events.NativeWindowBoundsEvent;

public class ExternalWindow extends Window{

    private var ane: OpenfinNativeExtention;
    private var _nativeWindow: NativeWindow;
    private var callBack: Function;
    private var hwnd: String;
    private var _moving: Boolean;

    public const WM_CAPTURECHANGED: uint = 0x0215;
    public const WM_DESTROY: uint = 0x0002;
    public const WM_ENTERSIZEMOVE: uint = 0x0231;
    public const WM_ERASEBKGND: uint = 0x0014;
    public const WM_EXITSIZEMOVE: uint = 0x0232;
    public const WM_KEYDOWN: uint = 0x0100;
    public const WM_KEYUP: uint = 0x0101;
    public const WM_KILLFOCUS: uint = 0x0008;
    public const WM_LBUTTONDOWN: uint = 0x0201;
    public const WM_LBUTTONUP: uint = 0x0202;
    public const WM_MOUSEMOVE: uint = 0x0200;
    public const WM_MOVE: uint = 0x0003;
    public const WM_MOVING: uint = 0x0216;
    public const WM_NCLBUTTONDBLCLK: uint = 0x00A3;
    public const WM_NCLBUTTONUP: uint = 0x00A2;
    public const WM_NOTIFY: uint = 0x4E;
    public const WM_SETFOCUS: uint = 0x0007;
    public const WM_SIZING: uint = 0x0214;
    public const WM_SYSCOMMAND: uint = 0x0112;
    public const WM_WINDOWPOSCHANGED: uint = 0x0047;
    public const WM_WINDOWPOSCHANGING: uint = 0x0046;
    public const WM_PAINT: uint = 0x000F;
    public const SWP_HIDEWINDOW: uint = 0x0080;
    public const SWP_NOMOVE: uint = 0x0002;
    public const SWP_NOSIZE: uint = 0x0001;
    public const SWP_SHOWWINDOW: uint = 0x0040;
    public const SC_CLOSE: uint = 0xF060;
    public const SC_MAXIMIZE: uint = 0xF030;
    public const SC_MINIMIZE: uint = 0xF020;
    public const SC_RESTORE: uint = 0xF120;
    public const VK_RETURN: uint = 0x0D;
    public const VK_SPACE: uint = 0x20;

    public function ExternalWindow(nativeWindow: NativeWindow, uuid: String, name: String, callback: Function = null, errorCallback: Function = null) {

        super (uuid, name);
        this.callBack = callback;
        _nativeWindow = nativeWindow;
        if(!ane)ane = new OpenfinNativeExtention();
        hwnd = ane.getHWND();
        sendMessage("register-external-window", {topic: "application", hwnd: hwnd , uuid:uuid, name: name}, onRegister, errorCallback);
        addEventListener(WindowEvent.FRAME_DISABLED, this._onFrameDisabled);
        addEventListener(WindowEvent.FRAME_ENABLED, this._onFrameEnabled);
        _nativeWindow.addEventListener(Event.ACTIVATE, onActivateChanged);
        _nativeWindow.addEventListener(Event.DEACTIVATE, onActivateChanged);
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

        _nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVING, _onDisabledFrameMoving);
      //  _nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, _onDisabledFrameMove);
        _nativeWindow.removeEventListener(NativeWindowBoundsEvent.MOVING, _onEnabledFrameMoving);
        //_nativeWindow.removeEventListener(NativeWindowBoundsEvent.MOVE, _onEnabledFrameMove);
    }

    private function addEnabledFrameListeners(): void{

        _nativeWindow.removeEventListener(NativeWindowBoundsEvent.MOVING, _onDisabledFrameMoving);
        //_nativeWindow.removeEventListener(NativeWindowBoundsEvent.MOVE, _onDisabledFrameMove);
        _nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVING, _onEnabledFrameMoving);
       // _nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, _onEnabledFrameMove);
    }

    private function _onDisabledFrameMoving(event: NativeWindowBoundsEvent): void{

        event.preventDefault();
        sendWindowMovingEvent(event);
        _moving = true;
    }

    private function _onEnabledFrameMoving(event: NativeWindowBoundsEvent): void{

        sendWindowMovingEvent(event);
        _moving = true;
    }

    private function _onEnabledFrameMove(event: NativeWindowBoundsEvent): void{

        sendWindowMoveEvent(event);
        _moving = false;
    }

    private function _onDisabledFrameMove(event: NativeWindowBoundsEvent): void{

        trace("mvoe complete............");
        event.preventDefault();
        sendWindowMoveEvent(event);
        _moving = false;
    }

    private function sendWindowMovingEvent(event: NativeWindowBoundsEvent): void{

        if(!_moving) {
            sendMessage("external-window-action", {
                type: WM_CAPTURECHANGED,
                hwnd: hwnd,
                uuid: _uuid,
                name: _name,
                lParam: 0
            });

            sendMessage("external-window-action", {
                type: WM_ENTERSIZEMOVE,
                uuid: _uuid,
                name: _name,
                mouseX: NativeWindow(event.target).stage.mouseX,
                mouseY: NativeWindow(event.target).stage.mouseY
            });
        }

        sendMessage("external-window-action", {

            type: WM_MOVING,
            uuid: _uuid,
            name: _name,
            mouseX: NativeWindow(event.target).stage.mouseX,
            mouseY: NativeWindow(event.target).stage.mouseY,
            left: event.afterBounds.left,
            top: event.afterBounds.top,
            right:event.afterBounds.right,
            bottom: event.afterBounds.bottom
        });

        sendMessage("external-window-action", {

            type: WM_WINDOWPOSCHANGING,
            uuid: _uuid,
            name: _name,
            x: event.afterBounds.x,
            y: event.afterBounds.y,
            cx: event.afterBounds.x - event.beforeBounds.x,
            cy: event.afterBounds.y - event.beforeBounds.y,
            flags: "",
            hwnd: hwnd,
            "hwndInsertAfter": "00000000"

        });
    }

    private function sendWindowMoveEvent(event: NativeWindowBoundsEvent): void{

        sendMessage("external-window-action", {

            type: WM_WINDOWPOSCHANGED,
            uuid: _uuid,
            name: _name,
            x: event.afterBounds.x,
            y: event.afterBounds.y,
            cx: event.afterBounds.x - event.beforeBounds.x,
            cy: event.afterBounds.y - event.beforeBounds.y,
            flags: "",
            hwnd: hwnd,
            hwndInsertAfter: "00000000"
        });

        sendMessage("external-window-action", {

            type: WM_MOVE,
            uuid: _uuid,
            name: _name,
            x: event.afterBounds.x,
            y: event.afterBounds.y
        });

        sendMessage("external-window-action", {
            type: WM_EXITSIZEMOVE,
            uuid: _uuid,
            name: _name,
            mouseX: NativeWindow(event.target).stage.mouseX,
            mouseY: NativeWindow(event.target).stage.mouseY
        });
    }

    private function onActivateChanged(event: Event): void{

        if(event.type == Event.ACTIVATE)
            sendMessage("external-window-action", {type: 0x0007 , uuid:_uuid, name: _name});
        else
            sendMessage("external-window-action", {type: 0x0008 , uuid:_uuid, name: _name});
    }
}
}
