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
    private var address: String;
    private var port: String;
    private var jsonURL: String;
    private var onComplete: Function;

    public function RuntimeLauncher(appJsonURL: String, onComplete: Function) {
        this.ane = new OpenfinNativeExtention();
        jsonURL = appJsonURL;
        this.onComplete = onComplete;
        initialiseProcess(appJsonURL);
    }

    private function initialiseProcess(jsonURL: String): void{
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
        processArgs[0] = "--config=" + jsonURL;
        processArgs[1] = '--runtime-arguments=--runtime-information-channel-v6=' + namedPipeName;
        trace("starting", processArgs[0], processArgs[1]);
        nativeProcessStartupInfo.arguments = processArgs;
        var runtimeProcess: NativeProcess = new NativeProcess();
        runtimeProcess.start(nativeProcessStartupInfo);

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
        trace("received status message:" + event.code);
        trace("received status message:" + event.level);
    }

    private function onOutputData(event: ProgressEvent): void{

        var process: NativeProcess = event.target as NativeProcess;
        var bytes: ByteArray = new ByteArray();
        process.standardOutput.readBytes(bytes);
        process.exit(true);

        var config: Object = getConfig(bytes.toString());
        var service: Object = config.services[0];
        address = service.addr;
        port = service.port;

        getUUID(jsonURL);
    }

    private function getConfig(output: String): Object{

        var index: int = output.indexOf("SURVEYKTHXBAI\r");
        return JSON.parse(output.substring(index + 16, output.indexOf("SurveyServer::Run", index)));
    }

    private function getUUID(jsonURL: String): void{

        var urlLoader: URLLoader = new URLLoader();
        urlLoader.addEventListener(Event.COMPLETE, this._onJSONLoaded);
        urlLoader.load(new URLRequest(jsonURL));
    }

    private function _onJSONLoaded(event: Event): void{

        var urlLoader: URLLoader = event.target as URLLoader;
        var data: Object = JSON.parse(urlLoader.data);
        trace(data.startup_app.uuid);
        new DesktopConnection(data.startup_app.uuid, address, port , onConnectionReady, onConnectionError);
    }

    private function onConnectionReady(): void{

        onComplete();
    }

    private function onConnectionError(reason: String): void{

        trace("there was an error connecting: ", reason);
    }

}
}
