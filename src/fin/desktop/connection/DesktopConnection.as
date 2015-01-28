/**
 * Created by haseebriaz on 19/01/2015.
 */
package fin.desktop.connection {
import com.worlize.websocket.WebSocket;
import com.worlize.websocket.WebSocketEvent;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class DesktopConnection extends EventDispatcher{

    private static var _instance: DesktopConnection;

    private var _messageId: int = -1;
    private var _state: String;
    private var _webSocket: WebSocket;
    private var _uuid: String;
    private var _onReady: Function;
    private var _onError: Function;
    private var _messageHandlers:Dictionary;

    public static function getInstance(): DesktopConnection{

        return _instance;
    }
    public function DesktopConnection(uuid: String, host: String, port: String, onReady: Function, onError: Function = null) {

        if(_instance) throw new Error("Only one instance of Desktop Connection is allowed, use DesktopConnection.getInstance()");

        _instance = this;
        _uuid = uuid;
        _onReady = onReady;
        _onError = onError;

        _messageHandlers = new Dictionary();

        createWebSocketConnection(host, port);
    }

    private function createWebSocketConnection(host: String, port: String): void{

        _webSocket = new WebSocket("ws://" + host + ":" + port, "*");
        _webSocket.addEventListener(WebSocketEvent.OPEN, onOpen);
        _webSocket.addEventListener(WebSocketEvent.MESSAGE, onMessage);
        _webSocket.connect();
    }

    private function onOpen(event: WebSocketEvent): void{

        trace("connection opened...");
        sendPreAuthorization();
    }

    private function sendPreAuthorization(): void{

        _state = "preAuth";
        sendMessage("request-external-authorization", {
            type: "file-token",
            uuid: _uuid,
            "authorizationToken": null
        })
    }

    private function sendAuthorization(): void{

        _state = "auth";
        sendMessage("request-authorization", {

            type: 'file-token',
            uuid: _uuid
        })
    }

    private function onMessage(event: WebSocketEvent): void{

        trace("RECIEVED: ", event.message.utf8Data);
        var response: Object = JSON.parse(event.message.utf8Data);

        switch(_state){

            case "preAuth":
                if(response.payload.success === false) {

                    if(_onError) _onError(response.payload.reason);
                } else {

                    sendAuthorization();
                }
                break;

            case "auth":
                _state =  "authorized";
                _onReady();
                break;

            case "authorized":
                processMessages(response);
                break;
        }
    }

    private function processMessages(response: Object): void{

        switch(response.action){

            case "ack":
                processAckMessage(response);
                break;

           default:
                processMessage(response);
                break;
        }
    }

    private function processAckMessage(response: Object): void{

        var handler: Object = _messageHandlers["ack" + response.correlationId];
        _messageHandlers["ack" + response.correlationId]  = null;

        if(!handler) return;

        if(response.payload.success) {

            callMethod(handler.success, response.payload.data);
        } else {

            callMethod(handler.fail, response.payload.reason);
        }
    }

    private function callMethod(method: Function, ...args): void{

        if(method) {
            if(method.length) {

                method.apply(null, args);
            } else {

                method();
            }
        }
    }

    private function processMessage(response: Object): void{

        dispatchEvent(new DesktopConnectionEvent(response.action, response.payload));
    }

    public function sendMessage(action: String, payload: Object = null, onMessage: Function = null, onError: Function = null): int{

        if(_messageId > 0 && (onMessage || onError)){

            _messageHandlers["ack" + _messageId] = {success: onMessage, fail: onError};
        }

        var json: Object = {action: action, payload: payload, messageId: _messageId};
        var message: String = JSON.stringify(json, _jsonFilter);
        _webSocket.sendUTF(message);

        trace("SENT: ", message);
        return _messageId++;
    }

    private function _jsonFilter(key: String, value: *): * {

        if(!value && value !== false){

            return undefined ;
        } else {

            return value;
        }
    }
}
}
