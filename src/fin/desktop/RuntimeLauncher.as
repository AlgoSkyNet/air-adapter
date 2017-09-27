/**
 * Created by haseebriaz on 02/02/2015.
 */
package fin.desktop {

import fin.desktop.connection.DesktopConnection;

import com.openfin.OpenfinNativeExtention;

import fin.desktop.logging.ILogger;

import fin.desktop.logging.LoggerFactory;

import flash.events.StatusEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.getQualifiedClassName;

public class RuntimeLauncher {
    private var ane: OpenfinNativeExtention;
    private var runtimeExec: String = "OpenFinRVM.exe";
    private var installerExec: String = "OpenFinInstaller.exe";
    private var port: String;
    private var desktopConnection: DesktopConnection;
    private var runtimeConfiguration: RuntimeConfiguration;
    private var logger:ILogger;

    private static var SECURITY_REALM_SETTING: String = "--security-realm="; // from runtime->arguments

    private static var DEFAULT_RUNTIME_WORK_PATH   : String = "AppData\\Local\\OpenFin";

    [Embed(source="/assets/OpenFinInstaller.exe", mimeType="application/octet-stream")]
    private var myAsset: Class;
    
    public function RuntimeLauncher(runtimeConfiguration: RuntimeConfiguration) {
        logger = LoggerFactory.getLogger(getQualifiedClassName(RuntimeLauncher));
        this.runtimeConfiguration = runtimeConfiguration;
        this.ane = new OpenfinNativeExtention();
		if (runtimeConfiguration.appManifestUrl)
		{
			getAppManifest();
		}
		else 
		{
			initialiseProcess();
		}
    }

    private function initialiseProcess(): void{
        var currTime:Date = new Date();
        var randomNum:Number = Math.floor(Math.random() * 100000);
        var namedPipeName:String = "OpenfinAirAdapter." + currTime.getTime() + "." + randomNum;
        logger.debug("calling discoverRuntime ", namedPipeName);
        ane.addEventListener(StatusEvent.STATUS, onStatusEvent);
        var workPath: String;
        var workExec: String;
        var workDir: File;
        if (runtimeConfiguration.runtimeInstallPath != null) {
            workDir = new File(runtimeConfiguration.runtimeInstallPath);
        } else {
            workDir = File.userDirectory.resolvePath(DEFAULT_RUNTIME_WORK_PATH);
        }
        var runtimeFile: File = workDir.resolvePath(runtimeExec);
        var installerArgs: String = " ";  // additional args only needed for Installer
        if (!runtimeFile.exists) {
            logger.debug(runtimeFile.nativePath, "desc not exist.  Unpacking", installerExec);
            workExec = installerExec;
            workPath = unpackInstaller();
            if (runtimeConfiguration.assetUrl != null) {
                installerArgs += " --assetsUrl=" + runtimeConfiguration.assetUrl;
            }
            if (runtimeConfiguration.runtimeInstallPath != null) {
                installerArgs += "/D=" + runtimeConfiguration.runtimeInstallPath;
            }
        } else {
            logger.debug(runtimeFile.nativePath, "exists");
            workExec = runtimeExec;
            workPath = workDir.nativePath;
        }
        var args: String = "--config=" + createRVMConfig(runtimeConfiguration) 
							+ ((runtimeConfiguration.showInstallerUI) ? " " : " --no-installer-ui ")
							+ ' --runtime-arguments="--v=1 --runtime-information-channel-v6=' + namedPipeName + '"' + installerArgs;
        logger.debug("invoking ", workPath, workExec, args);
        ane.launchRuntime(workPath, workExec, args, "chrome." + namedPipeName, runtimeConfiguration.connectionTimeout);
    }

    private function unpackInstaller(): String {
        var installer:ByteArray = new myAsset() as ByteArray;
        logger.debug("installer length", installer.length);
        var temp:File = File.createTempDirectory();
        logger.debug(temp.nativePath);
        var fs : FileStream = new FileStream();
        var targetFile : File = temp.resolvePath(installerExec);
        fs.open(targetFile, FileMode.WRITE);
        fs.writeBytes(installer,0,installer.length);
        fs.close();
        logger.debug("unpacked ", installerExec, " to ", targetFile.nativePath);
        return temp.nativePath;
    }

    private function onStatusEvent(event:StatusEvent): void {
        logger.debug("received status message:", event.code);
        logger.debug("received status message:", event.level);
        if (event.code == "PortDiscoverySuccessMessage") {
            // {"action":"runtime-information","payload":{"version":"7.53.20.20","sslPort":-1,"port":9696,"requestedVersion":"beta","securityRealm":"nucleus","runtimeInformationChannel":"OpenfinDesktop.81309855-23E6-E90F-B8B5-7E862895AB5A"}}
            var data: Object = JSON.parse(event.level);
            if (matchRuntimeInstance(data.payload.requestedVersion, data.payload.securityRealm)) {
                this.port = data.payload.port;
                logger.debug("Found matching Runtime", data.payload.version, "at port", this.port);
                desktopConnection = new DesktopConnection(runtimeConfiguration.connectionUuid, "localhost", port,
                        runtimeConfiguration.onConnectionReady, runtimeConfiguration.onConnectionError,
                        runtimeConfiguration.onConnectionClose);
                if (runtimeConfiguration.maxReceivedFrameSize > 0) {
                    desktopConnection.maxReceivedFrameSize = runtimeConfiguration.maxReceivedFrameSize;
                    logger.debug("Setting max frame size", desktopConnection.maxReceivedFrameSize);
                }
                if (runtimeConfiguration.maxMessageSize > 0) {
                    desktopConnection.maxMessageSize = runtimeConfiguration.maxMessageSize;
                    logger.debug("Setting max message size", desktopConnection.maxMessageSize);
                }
            } else {
                logger.debug("Ignoring PortDiscoverySuccessMessage");
            }
        }
        if (event.code == "PortDiscoveryErrorMessage") {
            runtimeConfiguration.onConnectionError(event.level);
        }
    }

    private function matchRuntimeInstance(requestedVersion: String, reportedSecurityRealm: String): Boolean {
        if (this.runtimeConfiguration.runtimeVersion != null && this.runtimeConfiguration.securityRealm != null){
            return this.runtimeConfiguration.runtimeVersion == requestedVersion &&
                        this.runtimeConfiguration.securityRealm == reportedSecurityRealm;
        }
        else if (this.runtimeConfiguration.runtimeVersion != null) {
            return this.runtimeConfiguration.runtimeVersion == requestedVersion && reportedSecurityRealm == null;
        }
        else {
            return false;
        }
    }

import flash.desktop.NativeProcess;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;


private function onOutputData(event: ProgressEvent): void{
        var process: NativeProcess = event.target as NativeProcess;
        var bytes: ByteArray = new ByteArray();
        process.standardOutput.readBytes(bytes);
        process.closeInput();
//        process.exit(false);
        logger.debug(bytes.toString());
    }

    private function getAppManifest(): void {
        logger.debug("retrieving", this.runtimeConfiguration.appManifestUrl);
        var urlLoader: URLLoader = new URLLoader();
        urlLoader.addEventListener(Event.COMPLETE, this._onJSONLoaded);
        urlLoader.load(new URLRequest(this.runtimeConfiguration.appManifestUrl));
    }

    private function _onJSONLoaded(event: Event): void{
        var urlLoader: URLLoader = event.target as URLLoader;
        var data: Object = JSON.parse(urlLoader.data);
        this.runtimeConfiguration.runtimeVersion = data.runtime.version;
        if (data.runtime.arguments != null) {
            var results:Array = data.runtime.arguments.split(" ");
            for (var i:String in results) {
                var setting: String = results[i];
                if (setting.indexOf(SECURITY_REALM_SETTING) == 0) {
                    this.runtimeConfiguration.securityRealm = setting.substr(SECURITY_REALM_SETTING.length);
                    logger.debug("runtime security realm from manifest", this.runtimeConfiguration.securityRealm);
                }
            }
        }
        logger.debug("runtime version from manifest", this.runtimeConfiguration.runtimeVersion);
        initialiseProcess();
    }
	
	public static function createRVMConfig(cfg:RuntimeConfiguration):String
	{
		if (!cfg.appManifestUrl)
		{
			var appCfgFile:File = File.createTempFile();
			var stream:FileStream = new FileStream();
			stream.open(appCfgFile, FileMode.WRITE);
			var configContent:String = cfg.generateRuntimeConfig();
			stream.writeUTFBytes(configContent);
			stream.close();
			trace("app.json file: " + appCfgFile.nativePath);
			trace("app.json content: " + configContent);
			return appCfgFile.nativePath;
		}
		else 
		{
			return cfg.appManifestUrl;
		}
	}


}
}
