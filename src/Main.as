/**
 * Created by haseebriaz on 19/01/15.
 */
package {

import flash.display.Sprite;
import fin.desktop.connection.DesktopConnection;

import tests.ApplicationTest;
import tests.InterApplicationBusTest;
import tests.NotificationTest;
import tests.WindowTests;

public class Main extends Sprite{

    private var connection: DesktopConnection;

    public function Main() {

      connection = new DesktopConnection("OpenFinJSAPITestBench", "localhost", "9696" , onConnectionReady, onConnectionError);
    }

    private function onConnectionError(reason: String): void{

        trace("there was an error:", reason);
    }

   private function onConnectionReady(){

       // new InterApplicationBusTest();
       //new NotificationTest();
      // new WindowTests();
       new ApplicationTest();

   }
}
}
