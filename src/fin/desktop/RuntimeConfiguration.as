/**
 * Created by richard on 5/27/2017.
 */
package fin.desktop {
import com.openfin.OpenfinNativeExtention;

import fin.desktop.logging.ILogger;
import fin.desktop.logging.LoggerFactory;

import flash.utils.getQualifiedClassName;

/**
 * Configuration for launching OpenFin Runtime
 */
public class RuntimeConfiguration {
    private var _connectionUuid: String;
    private var _appManifestUrl: String;
    private var _connectionTimeout:Number = 10000;
    private var _runtimeInstallPath: String;
    private var _assetUrl: String;
    private var _onConnectionReady: Function;
    private var _onConnectionClose: Function;
    private var _onConnectionError: Function;
    private var logger:ILogger;

    private static var ane: OpenfinNativeExtention;

    /**
     * Constructor
     * @param uuid uuid of the connection to Runtime
     */
    public function RuntimeConfiguration(uuid: String) {
        this._connectionUuid = uuid;
        logger = LoggerFactory.getLogger(getQualifiedClassName(RuntimeLauncher));
        logger.debug("created with uuid ", uuid);
    }
    
    public function get connectionUuid():String {
        return _connectionUuid;
    }

    /**
     * Get URL of app manifest
     */
    public function get appManifestUrl():String {
        return _appManifestUrl;
    }

    /**
     * Set URL of app manifest
     * @param value URL of app manifest
     */
    public function set appManifestUrl(value:String):void {
        _appManifestUrl = value;
    }

    /**
     * Get path of Runtime install location
     */
    public function get runtimeInstallPath():String {
        return _runtimeInstallPath;
    }

    /**
     * Set path of Runtime install location.  Default: %LocalAppData%/OpenFin
     * @param value path of install location
     */
    public function set runtimeInstallPath(value:String):void {
        _runtimeInstallPath = value;
    }

    /**
     * Get timeout in milli-seconds
     */
    public function get connectionTimeout():Number {
        return _connectionTimeout;
    }

    /**
     * Set timeout in milli-seconds
     *
     * @param value timeout in milli-seconds
     */
    public function set connectionTimeout(value:Number):void {
        _connectionTimeout = value;
    }


    /**
     * Get Runtime asset URL
     */
    public function get assetUrl():String {
        return _assetUrl;
    }

    /**
     * Set Runtime asset URL
     * @param value URL of Runtime assets
     */
    public function set assetUrl(value:String):void {
        _assetUrl = value;
    }

    /**
     * Get callback function for connection ready event
     */
    public function get onConnectionReady():Function {
        return _onConnectionReady;
    }

    /**
     * Set callback function for connection ready event
     * @param value callback function
     */
    public function set onConnectionReady(value:Function):void {
        _onConnectionReady = value;
    }

    /**
     * Get callback function for connection error event
      */
    public function get onConnectionError():Function {
        return _onConnectionError;
    }

    /**
     * Set callback function for connection error event
     * @param value callback function
     */
    public function set onConnectionError(value:Function):void {
        _onConnectionError = value;
    }

    /**
     * Get callback function for connection close event
     */
    public function get onConnectionClose():Function {
        return _onConnectionClose;
    }

    /**
     * Set callback function for connection close event
     * @param value callback function
     */
    public function set onConnectionClose(value:Function):void {
        _onConnectionClose = value;
    }

    /**
     * Enable logging to a log file
     * @param logFilename name of the log file in %LocalAppData%/OpenFin/logs
     */
    public static function enableFileLogging(logFilename:String=null):void {
        LoggerFactory.addFileLogger(logFilename);
    }

    /**
     * Enable logging with trace(...)
     */
    public static function enableTraceLogging():void {
        LoggerFactory.addTraceLogger();
    }

    public static function enableConsoleLogging():void {
        LoggerFactory.addConsoleLogger();
    }

    /**
     * Enable logging from native extension
     *
     * @param logFilePath  path to log file
     */
    public static function enableNativeExtensionLogging(logFilePath: String): void {
        if (!ane) {
            ane = new OpenfinNativeExtention();
        }
        ane.enableLogging(logFilePath, false);
    }

}
}
