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
    private var onComplete: Function;
    private var runtimeVersion: String; // from app manifest
    private var securityRealm: String;  // from app manifest
    private var desktopConnection: DesktopConnection;
    private var runtimeConfiguration: RuntimeConfiguration;

    public function RuntimeLauncher(runtimeConfiguration: RuntimeConfiguration) {
        this.runtimeConfiguration = runtimeConfiguration;
        this.ane = new OpenfinNativeExtention();
        this.onComplete = onComplete;
        getAppManifest();
    }

    private function initialiseProcess(): void{
        var namedPipeName:String = "OpenfinDesktop." + UIDUtil.createUID();
        trace("calling discoverRuntime " + namedPipeName);
        ane.addEventListener(StatusEvent.STATUS, onStatusEvent);
        ane.discoverRuntime("chrome." + namedPipeName, 10000);
        var nativeProcessStartupInfo: NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var workDir: File = File.userDirectory.resolvePath(runtimeWorkPath);
        nativeProcessStartupInfo.workingDirectory = workDir;
        var execFile: File = File.userDirectory.resolvePath(runtimeWorkPath + "\\" + runtimeExec);
        nativeProcessStartupInfo.executable = execFile;
        trace("invoking " + execFile.nativePath);
        var processArgs: Vector.<String> = new Vector.<String>();
        processArgs[0] = "--config=" + this.runtimeConfiguration.appManifestUrl;
        processArgs[1] = '--runtime-arguments=--runtime-information-channel-v6=' + namedPipeName;
        trace("starting", processArgs[0], processArgs[1]);
        nativeProcessStartupInfo.arguments = processArgs;
        var runtimeProcess: NativeProcess = new NativeProcess();
        runtimeProcess.start(nativeProcessStartupInfo);
//        runtimeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);

        if(runtimeProcess.running){
        }
    }

    private function launchProxyService(): void{
        var nativeProcessStartupInfo: NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var file: File = File.applicationDirectory.resolvePath("server.exe");
        nativeProcessStartupInfo.executable = file;
        var serverProcess: NativeProcess = new NativeProcess();
        serverProcess.start(nativeProcessStartupInfo);
        serverProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
    }

    private function onStatusEvent(event:StatusEvent): void {
        trace("received status message:", event.code);
        trace("received status message:", event.level);
        if (event.code == "PortDiscoveryMessage") {
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
    }

    private function onOutputData(event: ProgressEvent): void{
        var process: NativeProcess = event.target as NativeProcess;
        var bytes: ByteArray = new ByteArray();
        process.standardOutput.readBytes(bytes);
        process.exit(true);
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
