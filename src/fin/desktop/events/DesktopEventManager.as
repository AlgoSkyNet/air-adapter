/**
 * Created by haseebriaz on 27/01/2015.
 */
package fin.desktop.events {

import fin.desktop.connection.DesktopConnection;
import fin.desktop.connection.ResponseWaiter;
import flash.events.Event;
import flash.events.EventDispatcher;

public class DesktopEventManager {

    protected var _eventDispatcher: EventDispatcher;
    protected var _connection: DesktopConnection;
    protected var _defaultPayload: Object;
    protected var _eventTopic: String;

    public function DesktopEventManager(eventTopic: String) {

        _eventTopic = eventTopic;
        _eventDispatcher = new EventDispatcher();
        _connection = DesktopConnection.getInstance();
    }

    protected function sendMessage(action: String, payload: Object, callback: Function = null, errorCallback: Function = null): void{

        _connection.sendMessage(action, payload, callback, errorCallback);
    }

    /**
     * Registers an event listener on the specified event.
     * @param type  Event type
     * @param listener A listener that is called whenever an event of the specified type occurs
     * @param callback A function that is called if the method succeeds
     * @param errorCallback A function that is called if the method fails
     *
     */

    public function addEventListener(type: String, listener: Function, callback: Function = null, errorCallback: Function = null): void{

        if(_eventDispatcher.hasEventListener(type)){

            _eventDispatcher.addEventListener(type, listener);
            callback();
            return;
        }

        var waiter: ResponseWaiter  = new ResponseWaiter(addEventListenerCallback, type, listener, callback);
        sendMessage("subscribe-to-desktop-event", createPayload({topic: _eventTopic, type: type}), waiter.onResponse, errorCallback);
    }

    private function addEventListenerCallback(type: String, listener: Function, callback: Function): void{

        _eventDispatcher.addEventListener(type, listener);
        if(callback) callback();
    }

    /**
     * Removes a previously registered event listener from the specified event
     * @param type  Event type
     * @param listener A listener to remove
     * @param callback A function that is called if the method succeeds
     * @param errorCallback A function that is called if the method fails
     */
    public function removeEventListener(type: String, listener: Function, callback: Function = null, errorCallback: Function = null): void{

        _eventDispatcher.removeEventListener(type, listener);
        if(_eventDispatcher.hasEventListener(type)){

            callback();
        } else {

            var waiter:ResponseWaiter =  new ResponseWaiter(removeEventListenerCallback, type, listener, callback);
            sendMessage("unsubscribe-to-desktop-event", createPayload({topic:_eventTopic, type: type}), waiter.onResponse, errorCallback);
        }
    }

    private function removeEventListenerCallback(type: String, listener: Function, callback: Function): void{

        _eventDispatcher.removeEventListener(type, listener);
        if(callback) callback();
    }

    protected function createPayload(object: Object = null):Object {

        if(!object) return _defaultPayload;

        for(var p: String in _defaultPayload){

            object[p] = _defaultPayload[p];
        }

        return object;
    }

    public function dispatchEvent(event: Event): void{

        _eventDispatcher.dispatchEvent(event);
    }

}
}
