/**
 * Created by haseebriaz on 28/01/2015.
 */
package {
import fin.desktop.System;
import fin.desktop.connection.DesktopConnection;

import flash.display.Sprite;

public class SystemExample extends  Sprite{

    var connection: DesktopConnection;

    public function SystemExample() {

        connection = new DesktopConnection("OpenFinJSAPITestBench", "localhost", "9696" , onConnectionReady, onConnectionError);
    }

    private function onConnectionReady(): void{

        trace("connection successful!");
        System.getInstance().getVersion(versionCallback);
    }

    private function versionCallback(version: String): void{

        trace("the version is ", version);
    }

    private function getVersionFailed(reason: String): void{

        trace("there was a problem getting the version:", reason);
    }

    private function onConnectionError(reason: String): void{

        trace("There was an error in connecting:", reason);
    }
}
}
