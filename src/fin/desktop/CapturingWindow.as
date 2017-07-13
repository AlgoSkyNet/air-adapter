/**
 * Created by wenjun on 6/27/2017.
 */

package fin.desktop {
import com.openfin.OpenfinNativeExtention;

import fin.desktop.events.WindowEvent;

import fin.desktop.logging.ILogger;
import fin.desktop.logging.LoggerFactory;

import flash.display.NativeWindow;
import flash.utils.getQualifiedClassName;

public class CapturingWindow {

    private var ane: OpenfinNativeExtention;
    private var _nativeWindow: NativeWindow;
    private var _callBack: Function;
    private var _errorCallback: Function;
    private var _hwnd: String;
    private var _parentHWND: String;
    private var _appOptopns : ApplicationOptions;
    private var _windowOptopns : WindowOptions;
    private var _captureOptions: CaptureOptions;
    private var _parentApp: Application;
    private var _parentWindow: Window;
    private var logger:ILogger;

    public function CapturingWindow(nativeWindow: NativeWindow) {
        this.ane = new OpenfinNativeExtention();
        this._hwnd = ane.getHWND(ExternalWindow.AIR_WINDOW_CLASSNAME, nativeWindow.title);
        this._nativeWindow = nativeWindow;
        logger = LoggerFactory.getLogger(getQualifiedClassName(CapturingWindow));
    }

    public function capture(applicationOptions: ApplicationOptions, captureOptions: CaptureOptions, callback: Function = null, errorCallback: Function = null): void {
        this._appOptopns = applicationOptions;
        this._captureOptions = captureOptions;
        this._callBack = callback;
        this._errorCallback = errorCallback;
        this._parentApp = new Application(applicationOptions, onParentAppCreated, function (err:*): void {
            logger.info("Error creating capturing app", applicationOptions.uuid);
            if (_errorCallback is Function) {
                _errorCallback.apply(this, err);
            }
        });
    }

    public function detach(callback: Function = null): void {
        var ret: int = this.ane.detachAirWindow(_parentHWND, _hwnd);
        if (_callBack is Function) {
            var args:Array = [ret];
            _callBack.apply(this, args);
        }
    }

    private function onParentAppCreated(): void {
        logger.info("onParentAppCreated", _appOptopns.uuid);
        _parentWindow = new Window(this._appOptopns.uuid, this._appOptopns.uuid);
        _parentApp.run(onParentAppStarted, function (err:*): void  {
            logger.info("Error starting capturing app", _appOptopns.uuid);
            if (_errorCallback is Function) {
                _errorCallback.apply(this, err);
            }
        });
    }

    private function onParentAppStarted(): void {
        logger.info("onParentAppStarted", _appOptopns.uuid);
        _parentWindow.addEventListener("bounds-changing", onParentAppBoundsChanging);
        _parentWindow.addEventListener("shown", onParentAppShown);
        _parentWindow.addEventListener("focused", onParentAppFocused);
        _parentWindow.getNativeId(function (data:String): void {
            _parentHWND = data;
            logger.debug("sending capturing request for", _hwnd, " to ", _parentHWND);
            var ret: int = ane.captureAirWindow(_parentHWND, _hwnd, _captureOptions.borderTop,
                    _captureOptions.borderRight, _captureOptions.borderBottom, _captureOptions.borderLeft);
            if (_callBack is Function) {
                var args:Array = [ret];
                _callBack.apply(this, args);
            }
        });

    }

    private function onParentAppBoundsChanging(event: WindowEvent): void {
        logger.debug("updating bounds", event.type, _parentHWND, _hwnd);
        ane.updateCaptureWindowBounds(_parentHWND, _hwnd);
    }

    private function onParentAppShown(event: WindowEvent): void {
        if (_parentHWND) {
            _parentWindow.getState(function (state: String): void {
                if (state === "normal" || state === "maximized") {
                    logger.debug("updating bounds on shown", event.type, _parentHWND, _hwnd);
                    ane.updateCaptureWindowBounds(_parentHWND, _hwnd);
                } else {
                    logger.debug("ignoring onParentAppShown with state ", state);
                }
            });

        }
    }

    private function onParentAppFocused(event: WindowEvent): void {
        if (_parentHWND) {
            _parentWindow.getState(function (state: String): void {
                if (state === "normal" || state === "maximized") {
                    logger.debug("activate on focus", event.type, _parentHWND, _hwnd);
                    ane.updateCaptureWindowFocus(_parentHWND, _hwnd);
                } else {
                    logger.debug("ignoring onParentAppFocused with state ", state);
                }
            });

        }

    }

}
}
