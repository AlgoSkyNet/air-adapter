/**
 * Created by haseebriaz on 19/01/15.
 */
package {

import fin.desktop.Window;
import fin.desktop.WindowHandle;
import fin.desktop.RuntimeLauncher;
import fin.desktop.System;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.Sprite;
import fin.desktop.connection.DesktopConnection;

import flash.geom.Rectangle;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import tests.ApplicationTest;

import tests.InterApplicationBusTest;
import tests.NotificationTest;


public class Main extends Sprite{

    private var connection: DesktopConnection;
    private var process:NativeProcess;
    private var display: TextField;

    public function Main() {


        graphics.beginFill(0x00FF00);
        graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        display = new TextField();
        display.autoSize = TextFieldAutoSize.LEFT;
        display.multiline = true;
        addChild(display);
       // connection = new DesktopConnection("interapp-air", "localhost", "9696" , onConnectionReady, onConnectionError);

        new RuntimeLauncher("AppData\\Local\\OpenFin\\OpenFinRVM.exe", "http://openfin.github.io/excel-api-example/app.json", onConnectionReady);
    }

    private function onConnectionError(reason: String): void{

        trace("there was an error:", reason);
    }

    private function trace(...args){

        display.text += "\n" + args.join(", ");
    };

   private function onConnectionReady(){

     // new Window("", "testWindow");
      // var windowHandle: WindowHandle = new WindowHandle("test", stage.nativeWindow);
        new InterApplicationBusTest();
      // new NotificationTest();
      // new WindowTests();
       new ApplicationTest();

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
