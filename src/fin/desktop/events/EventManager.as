/**
 * Created by haseebriaz on 20/01/2015.
 */
package fin.desktop.events {
import flash.utils.Dictionary;

public class EventManager {

    private var _listeners: Dictionary;

    public function EventManager() {

        _listeners = new Dictionary();
    }

    public function addEventListener(type: String, listener: Function): void {

        var listeners: Vector.<Function> = _listeners[type]? _listeners[type]: _listeners[type] = new Vector.<Function>();
        if(listeners.indexOf(listener) < 0){

            listeners.push(listener);
        }
    }

    public function removeEventListener(type: String, listener: Function): int{

        var listeners: Vector.<Function> = _listeners[type];
        if(!listeners) return 0;

        listeners.splice(listeners.indexOf(listener), 1);

        return 0;
    }

    public function removeAllListeners(type: String): void{

        if(_listeners[type]) _listeners[type] = null;
    }

    public function hasEventListener(type: String): Boolean{

        return _listeners[type];
    }

    public function dispatchEvent(type: String, ...args): void{

        var listeners: Vector.<Function> = _listeners[type];

        for each(var listener: Function in listeners){

            listener.apply(null, args);
        }
    }
}
}
