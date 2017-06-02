/**
 * Created by haseebriaz on 02/02/2015.
 */
package fin.desktop {
import fin.desktop.connection.DesktopConnection;

import com.openfin.OpenfinNativeExtention;

import flash.desktop.NativeProcess;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.StatusEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import mx.utils.UIDUtil;

public class RuntimeLauncher {
    private var ane: OpenfinNativeExtention;
    private var runtimeExec: String = "OpenFinRVM.exe";
    private var installerExec: String = "OpenFinInstaller.exe";
    private var port: String;
    private var runtimeVersion: String; // from app manifest
    private var securityRealm: String;  // from app manifest
    private var desktopConnection: DesktopConnection;
    private var runtimeConfiguration: RuntimeConfiguration;

    private static var DEFAULT_RUNTIME_WORK_PATH   : String = "AppData\\Local\\OpenFin";
    private static var DEFAULT_INSTALLER_WORK_PATH : String = "AppData\\Local\\OpenFin";

    [Embed(source="/assets/OpenFinInstaller.exe", mimeType="application/octet-stream")]
    var myAsset: Class;
    
    public function RuntimeLauncher(runtimeConfiguration: RuntimeConfiguration) {
        this.runtimeConfiguration = runtimeConfiguration;
        this.ane = new OpenfinNativeExtention();
        getAppManifest();
    }

    private function initialiseProcess(): void{
        var namedPipeName:String = "OpenfinDesktop." + UIDUtil.createUID();
        trace("calling discoverRuntime " + namedPipeName);
        ane.addEventListener(StatusEvent.STATUS, onStatusEvent);
        var workPath: String;
        var workExec: String;
        var workDir: File;
        if (runtimeConfiguration.runtimeWorkPath != null) {
            workDir = new File(runtimeConfiguration.runtimeWorkPath);
        } else {
            workDir = File.userDirectory.resolvePath(DEFAULT_RUNTIME_WORK_PATH);
        }
        var runtimeFile: File = workDir.resolvePath(runtimeExec);
        if (!runtimeFile.exists) {
            trace(runtimeFile.nativePath, "desc not exist.  Unpacking", installerExec);
            workExec = installerExec;
            workPath = unpackInstaller();
        } else {
            trace(runtimeFile.nativePath, "exists");
            workExec = runtimeExec;
            workPath = workDir.nativePath;
        }
        var args: String = "--config=" + this.runtimeConfiguration.appManifestUrl +
                            ' --runtime-arguments=--runtime-information-channel-v6=' + namedPipeName;
        trace("invoking ", workPath, workExec, args);
        ane.launchRuntime(workPath, workExec, args, "chrome." + namedPipeName, runtimeConfiguration.connectionTimeout);
    }

    private function unpackInstaller(): String {
        var installer:ByteArray = new myAsset() as ByteArray;
        trace("installer length", installer.length);
        var temp:File = File.createTempDirectory();
        trace(temp.nativePath);
        var fs : FileStream = new FileStream();
        var targetFile : File = temp.resolvePath(installerExec);
        fs.open(targetFile, FileMode.WRITE);
        fs.writeBytes(installer,0,installer.length);
        fs.close();
        trace("unpacked ", installerExec, " to ", targetFile.nativePath);
        return temp.nativePath;
    }

    private function onStatusEvent(event:StatusEvent): void {
        trace("received status message:", event.code);
        trace("received status message:", event.level);
        if (event.code == "PortDiscoverySuccessMessage") {
            // {"action":"runtime-information","payload":{"version":"7.53.20.20","sslPort":-1,"port":9696,"requestedVersion":"beta","runtimeInformationChannel":"OpenfinDesktop.9418784F-DE54-BD14-36D1-4BF501C05FC7"}}
            var data: Object = JSON.parse(event.level);
            if (this.runtimeVersion == data.payload.requestedVersion) {
                this.port = data.payload.port;
                trace("Found matching Runtime", data.payload.version, "at port", this.port);
                desktopConnection = new DesktopConnection(runtimeConfiguration.connectionUuid, "localhost", port,
                        runtimeConfiguration.onConnectionReady, runtimeConfiguration.onConnectionError,
                        runtimeConfiguration.onConnectionClose);
            }
        }
        if (event.code == "PortDiscoveryErrorMessage") {
            runtimeConfiguration.onConnectionError(event.level);
        }
    }

    private function onOutputData(event: ProgressEvent): void{
        var process: NativeProcess = event.target as NativeProcess;
        var bytes: ByteArray = new ByteArray();
        process.standardOutput.readBytes(bytes);
        process.closeInput();
//        process.exit(false);
        trace(bytes.toString());
    }

    private function getAppManifest(): void {
        trace("retrieving", this.runtimeConfiguration.appManifestUrl);
        var urlLoader: URLLoader = new URLLoader();
        urlLoader.addEventListener(Event.COMPLETE, this._onJSONLoaded);
        urlLoader.load(new URLRequest(this.runtimeConfiguration.appManifestUrl));
    }

    private function _onJSONLoaded(event: Event): void{
        var urlLoader: URLLoader = event.target as URLLoader;
        var data: Object = JSON.parse(urlLoader.data);
        runtimeVersion = data.runtime.version;
        trace("runtime version from manifest", runtimeVersion);
        initialiseProcess();
    }

}
}
