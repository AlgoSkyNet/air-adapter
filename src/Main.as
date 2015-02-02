/**
 * Created by haseebriaz on 19/01/15.
 */
package {

import fin.desktop.RuntimeLauncher;
import fin.desktop.System;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.Sprite;
import fin.desktop.connection.DesktopConnection;


public class Main extends Sprite{

    private var connection: DesktopConnection;
    private var process:NativeProcess;

    public function Main() {

     // connection = new DesktopConnection("OpenFinJSAPITestBench", "localhost", "9696" , onConnectionReady, onConnectionError);
        new RuntimeLauncher("http://localhost:5000/app.json", onConnectionReady);
    }

    private function onConnectionError(reason: String): void{

        trace("there was an error:", reason);
    }

   private function onConnectionReady(){

       // new InterApplicationBusTest();
       //new NotificationTest();
      // new WindowTests();
      // new ApplicationTest();

       System.getInstance().getVersion(onVersionCallback);

   }

    private function onVersionCallback(version: String): void{

        trace("version is: ", version);
    }

    private function onVersionCallbackError(reason: String): void{

        trace("there was an error in getting the version", reason);
    }


}
}
