/**
 * Created by richard on 5/27/2017.
 */
package fin.desktop {
public class RuntimeConfiguration {
    private var _connectionUuid: String;
    private var _appManifestUrl: String;
    private var _onConnectionReady: Function;
    private var _onConnectionClose: Function;
    private var _onConnectionError: Function;

    public function RuntimeConfiguration(uuid: String) {
        this._connectionUuid = uuid;
    }
    
    public function get connectionUuid():String {
        return _connectionUuid;
    }

    public function get appManifestUrl():String {
        return _appManifestUrl;
    }

    public function set appManifestUrl(value:String):void {
        _appManifestUrl = value;
    }

    public function get onConnectionReady():Function {
        return _onConnectionReady;
    }

    public function set onConnectionReady(value:Function):void {
        _onConnectionReady = value;
    }

    public function get onConnectionError():Function {
        return _onConnectionError;
    }

    public function set onConnectionError(value:Function):void {
        _onConnectionError = value;
    }
    
    public function get onConnectionClose():Function {
        return _onConnectionClose;
    }

    public function set onConnectionClose(value:Function):void {
        _onConnectionClose = value;
    }
}
}
