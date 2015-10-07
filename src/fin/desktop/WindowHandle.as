/**
 * Created by haseebriaz on 01/06/2015.
 */
package fin.desktop {
import flash.display.NativeWindow;
import flash.events.NativeWindowBoundsEvent;
import flash.external.ExtensionContext;

public class WindowHandle {

    private static var _instances:Array = [];

    public var name: String;
    private var nativeWindow: NativeWindow;
    public static var initialized: Boolean;

    public static function init(): void{

        initialized = true;
        InterApplicationBus.getInstance().subscribe("*", "airwindow", onBusMessage );

    }

    public static function onBusMessage(message: *, uuid: String){

        var name: String = message.windowName;
        switch(message.action){

            case "move": getWindowHandleByName(name).move(Math.random() * 800, Math.random() * 600);
                break;
        }
    }

    public static function getWindowHandleByName(name: String): WindowHandle{

        for(var i: int = 0; i < _instances.length; i++){

            if(_instances[i].name == name){
                return _instances[i];
            }
        }

        return null;
    }

    public function WindowHandle(name: String, nativeWindow: NativeWindow = null) {

        this.name = name;
        this.nativeWindow = nativeWindow;
        nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVING, onMoving);
        _instances.push(this);
        init();
    }

    public function onMoving(event: NativeWindowBoundsEvent){

        event.stopPropagation();
        event.preventDefault();
    }

    public function move(x: int, y: int): void{

        nativeWindow.x = x;
        nativeWindow.y = y;
    }
}
}

