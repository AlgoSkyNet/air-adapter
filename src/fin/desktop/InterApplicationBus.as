/**
 * Created by haseebriaz on 20/01/2015.
 */
package fin.desktop {
import fin.desktop.connection.DesktopConnection;
import fin.desktop.connection.DesktopConnectionEvent;
import fin.desktop.events.EventManager;

public class InterApplicationBus {

    private static var _instance: InterApplicationBus;

    private var _connection: DesktopConnection;
    private var _eventManager: EventManager;

    public function InterApplicationBus() {

        if(_instance) throw new Error("Only one instance is allowed.");

        _connection = DesktopConnection.getInstance();
        _connection.addEventListener(DesktopConnectionEvent.PROCESS_BUS_MESSAGE, onBusMessage);
        _connection.addEventListener(DesktopConnectionEvent.SUBSCRIBER_ADDED, onSubscriberAdded);
        _connection.addEventListener(DesktopConnectionEvent.SUBSCRIBER_REMOVED, onSubscriberRemoved);

        _eventManager = new EventManager();

        _instance = this;
    }

    public static function getInstance(): InterApplicationBus {

        return _instance? _instance : _instance = new InterApplicationBus();
    }

    private function onBusMessage(event: DesktopConnectionEvent): void{

        var payload: Object = event.payload;

        _eventManager.dispatchEvent(payload.topic, payload.message, payload.sourceUuid);
        _eventManager.dispatchEvent(payload.sourceUuid + payload.topic, payload.message, payload.sourceUuid);
    }

    private function onSubscriberAdded(event: DesktopConnectionEvent): void{

        var payload: Object = event.payload;
        _eventManager.dispatchEvent(event.type, payload.uuid, payload.topic);
    }

    private function onSubscriberRemoved(event: DesktopConnectionEvent): void{

        var payload: Object = event.payload;
        _eventManager.dispatchEvent(event.type, payload.uuid, payload.topic);
    }

    private  function sendMessage(action: String, payload: Object, callback: Function = null, errorCallback: Function = null): void{

        _connection.sendMessage(action, payload, callback, errorCallback);
    }

    public  function subscribe(sourceUuid: String, topic: String, listener: Function, callback: Function = null, errorCallback: Function = null): void{

        var eventType: String = sourceUuid === "*"? topic: sourceUuid + topic;

        if(_eventManager.hasEventListener(eventType)){

            _eventManager.addEventListener(eventType, listener);
            callback();
            return;
        }

        var onResponse: Function = function(){

            _eventManager.addEventListener(eventType, listener);
            if(callback)callback();
        }
        sendMessage("subscribe", {sourceUuid: sourceUuid, topic: topic}, onResponse, errorCallback);
    }

    public function unsubscribe(sourceUuid: String, topic: String, listener: Function, callback: Function = null, errorCallback: Function = null): void{

        var eventType: String = sourceUuid === "*"? topic: sourceUuid + topic;

        if(_eventManager.removeEventListener(eventType, listener) > 0){

            callback();
            return;
        }
        sendMessage("unsubscribe", {sourceUuid: sourceUuid, topic: topic}, callback, errorCallback);
    }

    public function send(destinationUuid: String, topic: String, message: *): void{

        sendMessage("send-message", {destinationUuid: destinationUuid, topic: topic, message: message});
    }

    public function publish(topic: String, message: *): void{

        sendMessage("publish-message", {topic: topic, message: message});
    }

    //function listener(uuid: String, topic: String)
    public function addSubscribeListener(listener: Function): void{

        _eventManager.addEventListener(DesktopConnectionEvent.SUBSCRIBER_ADDED, listener);
    }

    public function removeSubscribeListener(listener: Function): void{

        _eventManager.removeEventListener(DesktopConnectionEvent.SUBSCRIBER_ADDED, listener);
    }

    //function listener(uuid: String, topic: String)
    public function addUnsubscribeListener(listener: Function): void{

        _eventManager.addEventListener(DesktopConnectionEvent.SUBSCRIBER_REMOVED, listener);
    }

    public function removeUnsubscribeListener(listener: Function): void{

        _eventManager.removeEventListener(DesktopConnectionEvent.SUBSCRIBER_REMOVED, listener);
    }
}
}
