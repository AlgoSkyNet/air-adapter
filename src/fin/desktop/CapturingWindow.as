/**
 * Created by wenjun on 6/27/2017.
 */

package fin.desktop {
import com.openfin.OpenfinNativeExtention;

import fin.desktop.events.WindowEvent;

import fin.desktop.logging.ILogger;
import fin.desktop.logging.LoggerFactory;

import flash.display.NativeWindow;
import flash.events.Event;
import flash.utils.getQualifiedClassName;

public class CapturingWindow {
    public static var AIR_WINDOW_CLASSNAME: String = "ApolloRuntimeContentWindow";

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
        this._hwnd = ane.getHWND(AIR_WINDOW_CLASSNAME, nativeWindow.title);
        this._nativeWindow = nativeWindow;
        logger = LoggerFactory.getLogger(getQualifiedClassName(CapturingWindow));
    }

    public function capture(applicationOptions: ApplicationOptions, captureOptions: CaptureOptions, callback: Function = null, errorCallback: Function = null): void {
        this._appOptopns = applicationOptions;
        this._captureOptions = captureOptions;
        this._callBack = callback;
        this._errorCallback = errorCallback;
        this._parentApp = new Application(applicationOptions, onParentAppCreated, function (err:*) {
            logger.info("Error creating capturing app", applicationOptions.uuid);
            if (_errorCallback) {
                _errorCallback.apply(this, err);
            }
        });
    }

    private function onParentAppCreated(): void {
        logger.info("onParentAppCreated", _appOptopns.uuid);
        _parentWindow = new Window(this._appOptopns.uuid, this._appOptopns.uuid);
        _parentApp.run(onParentAppStarted, function (err:*) {
            logger.info("Error starting capturing app", _appOptopns.uuid);
            if (_errorCallback) {
                _errorCallback.apply(this, err);
            }
        });
    }

    private function onParentAppStarted(): void {
        logger.info("onParentAppStarted", _appOptopns.uuid);
        _parentWindow.addEventListener("bounds-changing", onParentAppBoundsChanging);
        _parentWindow.addEventListener("shown", onParentAppShown);
        _parentWindow.addEventListener("focused", onParentAppFocused);
        _parentWindow.getNativeId(function (data:String) {
            trace(data);
            _parentHWND = data;
            logger.debug("sending capturing request for", _hwnd, " to ", _parentHWND);
            var ret: int = ane.captureAirWindow(_parentHWND, _hwnd, _captureOptions.borderTop,
                    _captureOptions.borderRight, _captureOptions.borderBottom, _captureOptions.borderLeft);
            if (_callBack) {
                var args:Array = [ret];
                _callBack.apply(this, args);
            }

            _parentWindow.getBounds(onParentAppInitBounds);
//            _parentWindow.show();
        });

    }

    private function onParentAppInitBounds(bounds: Object): void {
        logger.debug("updating init bounds", JSON.stringify(bounds), _appOptopns.uuid, _parentHWND, _hwnd);
        _parentWindow.moveBy(1,0);
        _parentWindow.moveBy(-1,0);
//        var notes: String = "updating init bounds " + _parentHWND + " bounds " + bounds.width + ":" + bounds.height;
//        ane.updateCaptureWindowBounds(_parentHWND, _hwnd, notes, bounds.width, bounds.height);
    }

    private function onParentAppBoundsChanging(event: WindowEvent): void {
        logger.debug("updating bounds", event.type, _parentHWND, _hwnd);
        ane.updateCaptureWindowBounds(_parentHWND, _hwnd, "onParentAppBoundsChanging " + _parentHWND);
    }

    private function onParentAppShown(event: WindowEvent): void {
        if (_parentHWND) {
            logger.debug("updating bounds on shown", event.type, _parentHWND, _hwnd);
            ane.updateCaptureWindowBounds(_parentHWND, _hwnd, "onParentAppShown " + _parentHWND);
            // the following 2 moveBy trigger bounds-changing events so updateCaptureWindowBounds is called to adjust bounds of Ahr window to fit OpenFin window
            _parentWindow.moveBy(1,0);
            _parentWindow.moveBy(-1,0);
        }
    }

    private function onParentAppFocused(event: WindowEvent): void {
        logger.debug("activate on focus", event.type, _parentHWND, _hwnd);
        ane.updateCaptureWindowFocus(_parentHWND, _hwnd);
    }

}
}
