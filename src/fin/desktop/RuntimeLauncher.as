/**
 * Created by haseebriaz on 02/02/2015.
 */
package fin.desktop {
import fin.desktop.connection.DesktopConnection;

import com.openfin.OpenfinNativeExtention;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.StatusEvent;
import flash.filesystem.File;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import mx.utils.UIDUtil;

public class RuntimeLauncher {
    private var ane: OpenfinNativeExtention;
    private var runtimeWorkPath: String = "AppData\\Local\\OpenFin";
    private var runtimeExec: String = "OpenFinRVM.exe";
    private var port: String;
    private var runtimeVersion: String; // from app manifest
    private var securityRealm: String;  // from app manifest
    private var desktopConnection: DesktopConnection;
    private var runtimeConfiguration: RuntimeConfiguration;

    public function RuntimeLauncher(runtimeConfiguration: RuntimeConfiguration) {
        this.runtimeConfiguration = runtimeConfiguration;
        this.ane = new OpenfinNativeExtention();
        getAppManifest();
    }

    private function initialiseProcess(): void{
        var namedPipeName:String = "OpenfinDesktop." + UIDUtil.createUID();
        trace("calling discoverRuntime " + namedPipeName);
        ane.addEventListener(StatusEvent.STATUS, onStatusEvent);
        var workDir: File = File.userDirectory.resolvePath(runtimeWorkPath);
        var args: String = "--config=" + this.runtimeConfiguration.appManifestUrl + 
                            ' --runtime-arguments=--runtime-information-channel-v6=' + namedPipeName;
        trace("invoking ", workDir.nativePath, runtimeExec, args);
        ane.launchRuntime(workDir.nativePath, runtimeExec, args, "chrome." + namedPipeName, runtimeConfiguration.connectionTimeout);
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
        trace("retrieving" + this.runtimeConfiguration.appManifestUrl);
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
