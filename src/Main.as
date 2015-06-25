/**
 * Created by haseebriaz on 19/01/15.
 */
package {

import fin.desktop.ExternalWindow;
import fin.desktop.ExternalWindow;
import fin.desktop.Window;
import fin.desktop.Window;
import fin.desktop.WindowHandle;
import fin.desktop.RuntimeLauncher;
import fin.desktop.System;
import fin.desktop.events.WindowEvent;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.NativeWindow;
import flash.display.Sprite;
import fin.desktop.connection.DesktopConnection;

import flash.geom.Rectangle;
import flash.system.ApplicationDomain;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import tests.ApplicationTest;

import tests.InterApplicationBusTest;
import tests.NotificationTest;
import tests.WindowTests;


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
        connection = new DesktopConnection("interapp-air", "localhost", "9696" , onConnectionReady, onConnectionError);

       // new RuntimeLauncher("AppData\\Local\\OpenFin\\OpenFinRVM.exe", "http://openfin.github.io/excel-api-example/app.json", onConnectionReady);
    }

    private function onConnectionError(reason: String): void{

        trace("there was an error:", reason);
    }



   private function onConnectionReady(){

     // new Window("", "testWindow");
      // var windowHandle: WindowHandle = new WindowHandle("test", stage.nativeWindow);
      //  new InterApplicationBusTest();
      // new NotificationTest();
      // new WindowTests();
       //new ApplicationTest();
    //   new WindowTests();

       System.getInstance().getVersion(onVersionCallback);

       var exWindow: ExternalWindow = new ExternalWindow(stage.nativeWindow, "grid", "interapp-air");
       exWindow.joinGroup(new Window("grid", "grid"));


       System.getInstance().getAllWindows(function(windows: Array){

           for(var i = 0; i < windows.length; i++){

               if(windows[i].mainWindow)trace(windows[i].mainWindow.name, windows[i].mainWindow.uuid);
               var childWindows = windows[i].childWindows;

               for(var j = 0; j < childWindows.length; j++){

                   if(childWindows[j])trace(childWindows[j].name, childWindows[j].uuid);
               }
           }
       })


   }

    private function boundsChnaged(event: WindowEvent): void{

        trace("bounds changed");
    }

    private function onVersionCallback(version: String): void{

        trace("version is: ", version);
    }

    private function onVersionCallbackError(reason: String): void{

        trace("there was an error in getting the version", reason);

    }


}
}
