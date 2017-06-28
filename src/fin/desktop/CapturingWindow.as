/**
 * Created by wenjun on 6/27/2017.
 */

package fin.desktop {
import com.openfin.OpenfinNativeExtention;

import fin.desktop.logging.ILogger;
import fin.desktop.logging.LoggerFactory;

import flash.display.NativeWindow;
import flash.utils.getQualifiedClassName;

public class CapturingWindow {
    private var ane: OpenfinNativeExtention;
    private var _nativeWindow: NativeWindow;
    private var _callBack: Function;
    private var _errorCallback: Function;
    private var hwnd: String;
    private var _appOptopns : ApplicationOptions;
    private var _windowOptopns : WindowOptions;
    private var _captureOptions: CaptureOptions;
    private var _parentApp: Application;
    private var logger:ILogger;

    public function CapturingWindow(nativeWindow: NativeWindow, callback: Function = null, errorCallback: Function = null) {
        this.ane = new OpenfinNativeExtention();
        this.hwnd = ane.getHWND();
        this._callBack = callback;
        this._errorCallback = errorCallback;
        logger = LoggerFactory.getLogger(getQualifiedClassName(CapturingWindow));
    }

    public function Capture(applicationOptions: ApplicationOptions, captureOptions: CaptureOptions): void {
        this._appOptopns = applicationOptions;
        this._captureOptions = captureOptions;
        this._parentApp = new Application(applicationOptions, onParentAppCreated, function (err:*) {
            logger.info("Error creating capturing app", applicationOptions.uuid);
            if (_errorCallback) {
                _errorCallback.apply(this, err);
            }
        });
    }

    private function onParentAppCreated(): void {
        _parentApp.run(onParentAppStarted, function (err:*) {
            logger.info("Error starting capturing app", _appOptopns.uuid);
            if (_errorCallback) {
                _errorCallback.apply(this, err);
            }
        });
    }

    private function onParentAppStarted(): void {
        var w:Window = new Window(this._appOptopns.uuid, this._appOptopns.uuid);
        w.getNativeId(function (data:String) {
            trace(data);
            var parentHWND = data;
            var childHWND = hwnd;
            logger.debug("sending capturing request for", childHWND, " to ", parentHWND)
            ane.captureAirWindow(parentHWND, childHWND, _captureOptions.borderTop,
                    _captureOptions.borderRight, _captureOptions.borderBottom, _captureOptions.borderLeft);
        });

    }


}
}
