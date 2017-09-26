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
	private var _maxMessageSize: uint = 0;  // 0 means using default set by WebSocket library
	private var _maxReceivedFrameSize:uint = 0;
    private var _runtimeInstallPath: String;
    private var _assetUrl: String;
    private var _onConnectionReady: Function;
    private var _onConnectionClose: Function;
    private var _onConnectionError: Function;
    private var logger:ILogger;
	
	private var _devToolsPort:int;
    private var _runtimeVersion:String = "stable";
    private var _runtimeFallbackVersion:String;
    private var _securityRealm:String;
    private var _additionalRuntimeArguments:String;
	private var _startupApp:Object;
    private var _appAssets:Array;
    private var _rdmURL:String;
    private var _runtimeAssetURL:String;
    private var _additionalRvmArguments:String;
    private var _licenseKey:String;
    private var _configMap:Object;  // used to add any random config setting to app json file
    private var _launchWithRVM:Boolean = false;  // true -> launch RVM instead of installer
    private var _showInstallerUI:Boolean = false;  // default to silent mode

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
	 * Set max message size
     * @param size
     */
    public function set maxReceivedFrameSize(size: uint): void {
        _maxReceivedFrameSize = size;
    }

    /**
     * Get max message size
     */
    public function get maxReceivedFrameSize(): uint {
        return _maxReceivedFrameSize;
    }

    /**
	 * Set max frame message size
     * @param size
     */
    public function set maxMessageSize(size: uint): void {
        _maxMessageSize = size;
    }

    /**
     * Get max frame message size
     */
    public function get maxMessageSize(): uint {
        return _maxMessageSize;
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
     * @param logFilePath  path to log file.
     * @param verbose  true to enable verbose logging
     */
    public static function enableNativeExtensionLogging(logFilePath: String, verbose: Boolean = false): void {
        if (!ane) {
            ane = new OpenfinNativeExtention();
        }
        ane.enableLogging(logFilePath, verbose);
    }
	
	/**
     * Set version number of Runtime to launch
     * @param version version number
     */
	public function set runtimeVersion(runtimeVersion:String):void 
	{
		this._runtimeVersion = runtimeVersion;
	}
	
	/**
     * Get version number of Runtime
     * @return version of Runtime
     */
	public function get runtimeVersion():String 
	{
		return this._runtimeVersion;
	}
	
	/**
     * Set configuration of startup application.
     *
     * @param startupApp configuration in JSON format
     */
	public function set startupApp(startupApp:Object):void 
	{
		this._startupApp = startupApp;
	}
	
	/**
     * Get fallback version number of Runtime to launch
     *
     * @return fallback version
     */
	public function get runtimeFallbackVersion():String 
	{
		return _runtimeFallbackVersion;
	}
	
	/**
     * Set fallback version number of Runtime to launch
     *
     * @param runtimeFallbackVersion fallback version of Runtime
     */
	public function set runtimeFallbackVersion(value:String):void 
	{
		_runtimeFallbackVersion = value;
	}
	
	/**
     * Set additional arguments for Runtime
     *
     * @param additionalRuntimeArguments additional arguments
     */
	public function set additionalRuntimeArguments(value:String):void 
	{
		_additionalRuntimeArguments = value;
	}
	
	/**
     * Get security realm
     * @return security realm
     */
	public function get securityRealm():String 
	{
		return _securityRealm;
	}
	
	/**
     * Set security realm of Runtime
     *
     * @param securityRealm name of security realm
     */
	public function set securityRealm(value:String):void 
	{
		_securityRealm = value;
	}
	
	/**
     * Get URL of RDM service
     *
     * @return URL of RDM service
     */
	public function get rdmURL():String 
	{
		return _rdmURL;
	}
	
	/**
     * Set URL of RDM service
     *
     * @param rdmURL RDM URL
     */
	public function set rdmURL(value:String):void 
	{
		_rdmURL = value;
	}
	
	/**
     * Get URL of Runtime assets
     *
     * @return URL of Runtime assets
     */
	public function get runtimeAssetURL():String 
	{
		return _runtimeAssetURL;
	}
	
	/**
     * Set URL of Runtime assets, including RVM and Runtime
     *
     * @param runtimeAssetURL URL of Runtime assets
     */
	public function set runtimeAssetURL(value:String):void 
	{
		_runtimeAssetURL = value;
	}
	
	/**
     * Get additional arguments for RVM and Installer
     *
     * @return additional arguments
     */
	public function get additionalRvmArguments():String 
	{
		return _additionalRvmArguments;
	}
	
	/**
     * Set additional arguments for RVM and Installer
     *
     * @param additionalRvmArguments set additional arguments
     */
	public function set additionalRvmArguments(value:String):void 
	{
		_additionalRvmArguments = value;
	}
	
	/**
     * Get license key for Runtime
     *
     * @return license key
     */
	public function get licenseKey():String 
	{
		return _licenseKey;
	}
	
	/**
     * Set license key for Runtime
     *
     * @param licenseKey license key
     */
	public function set licenseKey(value:String):void 
	{
		_licenseKey = value;
	}
	
	/**
     * return value of launchWithRVM
     *
     * @return true or false
     */
	public function get launchWithRVM():Boolean 
	{
		return _launchWithRVM;
	}
	
	/**
     * By default, AIR adapter launches Runtime with OpenFin installer.  If launchWithRVM is true, installer is skipped and RVM is started instead.
     *
     * @param launchWithRVM true or false
     */
	public function set launchWithRVM(value:Boolean):void 
	{
		_launchWithRVM = value;
	}
	
	/**
     * Get if OpenFinInstaller should be invoked with UI
     * @return boolean value of showInstallUI
     */
	public function get showInstallerUI():Boolean 
	{
		return _showInstallerUI;
	}
	
	/**
     * Set if OpenFinInstaller should be invoked with UI.  Defaults to false
     *
     * @param showInstallerUI value of showInstallerUI
     *
     */
	public function set showInstallerUI(value:Boolean):void 
	{
		_showInstallerUI = value;
	}
	
	public function get appAssets():Array 
	{
		return _appAssets;
	}
	
	public function set appAssets(value:Array):void 
	{
		_appAssets = value;
	}
	
	public function addConfigurationItem(name:String, value:*):void 
	{
		if (!this._configMap)
		{
			this._configMap = new Object();
		}
		this._configMap[name] = value;
	}
	
	public function generateRuntimeConfig():String 
	{
		var config:Object = new Object();
		//devToolsPort
		if (this._devToolsPort > 0)
		{
			config.devtools_port = this._devToolsPort;
		}
		
		//runtimeConfig
		var runtime:Object = new Object();
		if (this._runtimeVersion)
		{
			runtime.version = this._runtimeVersion;
		}
		if (this._runtimeFallbackVersion) {
            runtime.fallbackVersion = this._runtimeFallbackVersion;
        }
		if (this._additionalRuntimeArguments != null) {
			runtime.arguments = this._additionalRuntimeArguments;
		}
		config.runtime = runtime;
		
		//rdmUrl
		if (this._rdmURL)
		{
			config.rdmUrl = this._rdmURL;
		}
		
		//runtimeAssetsURL
		if (this._runtimeAssetURL)
		{
			config.assetsUrl = this._runtimeAssetURL;
		}
		
		//appAssets
		if (this._appAssets && this._appAssets.length > 0)
		{
			config.appAssets = this._appAssets;
		}
		
		//startup_app
		if (this._startupApp != null) {
            config.startup_app = this._startupApp;
        }

		//additional config items
		if (this._configMap)
		{
			for (var key:* in this._configMap) 
			{
				config[key] = this._configMap[key];
			}
		}
		
		//license key
		if (this._licenseKey)
		{
			config.licenseKey = this._licenseKey;
		}
		
		return JSON.stringify(config);
	}

}
}
