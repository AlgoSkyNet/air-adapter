/**
 * Created by haseebriaz on 02/02/2015.
 */
package fin.desktop {
import fin.desktop.connection.DesktopConnection;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;

public class RuntimeLauncher {

    public static var runtimePath: String = "AppData\\Local\\OpenFin\\runtime\\3.0.2.11a\\OpenFin\\OpenFin.exe";
    private var address: String;
    private var port: String;
    private var jsonURL: String;
    private var onComplete: Function;

    public function RuntimeLauncher(appJsonURL: String, onComplete) {

        jsonURL = appJsonURL;
        this.onComplete = onComplete;
        initialiseProcess(appJsonURL);
    }

    private function initialiseProcess(jsonURL: String): void{

        var nativeProcessStartupInfo: NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var file: File = File.userDirectory.resolvePath(runtimePath);
        nativeProcessStartupInfo.executable = file;

        var processArgs: Vector.<String> = new Vector.<String>();
        processArgs[0] = "--startup-url=" + jsonURL;
        nativeProcessStartupInfo.arguments = processArgs;

        var runtimeProcess = new NativeProcess();
        runtimeProcess.start(nativeProcessStartupInfo);

        if(runtimeProcess.running){

            launchProxyService();
        }
    }

    private function launchProxyService(): void{

        var nativeProcessStartupInfo: NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var file: File = File.applicationDirectory.resolvePath("server.exe");
        nativeProcessStartupInfo.executable = file;

        var serverProcess = new NativeProcess();
        serverProcess.start(nativeProcessStartupInfo);
        serverProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
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
