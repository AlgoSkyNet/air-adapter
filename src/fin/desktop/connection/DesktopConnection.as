/**
 * Created by haseebriaz on 19/01/2015.
 */
package fin.desktop.connection {
import com.worlize.websocket.WebSocket;
import com.worlize.websocket.WebSocketCloseStatus;
import com.worlize.websocket.WebSocketError;
import com.worlize.websocket.WebSocketErrorEvent;
import com.worlize.websocket.WebSocketEvent;

import fin.desktop.RuntimeLauncher;

import fin.desktop.logging.ILogger;
import fin.desktop.logging.LoggerFactory;

import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import mx.core.ILayoutDirectionElement;

public class DesktopConnection extends EventDispatcher{

    private static var _instance: DesktopConnection;

    private var _messageId: int = -1;
    private var _state: String;
    private var _webSocket: WebSocket;
    private var _uuid: String;
    private var _onReady: Function;
    private var _onError: Function;
    private var _onClose: Function;
    private var _messageHandlers:Dictionary;
    private var _logger:ILogger;
    private var _valid:Boolean;
    
    public static function getInstance(): DesktopConnection{
        return _instance;
    }
    public function DesktopConnection(uuid: String, host: String, port: String, onReady: Function, onError: Function = null, onClose: Function = null) {

        if(_instance) {
            if (_instance._webSocket && _instance._webSocket.connected) {
                _instance._logger.debug("DesktopConnection is already connected");
                throw new Error("Only one instance of Desktop Connection is allowed, use DesktopConnection.getInstance()");
            } else if (_instance._webSocket) {
                _instance._logger.debug("reset stable connection");
                _instance._valid = false;
                _instance._webSocket.removeEventListener(WebSocketEvent.OPEN, onOpen);
                _instance._webSocket.removeEventListener(WebSocketEvent.MESSAGE, onMessage);
                _instance._webSocket.removeEventListener(WebSocketEvent.CLOSED, onClose);
                _instance._webSocket.removeEventListener(WebSocketErrorEvent.CONNECTION_FAIL, onConnectionFail);
                _instance._webSocket.removeEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, onAbnormalConnection);
                _instance._webSocket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);

                _instance._webSocket = null;
                _instance = null;
            }
        }

        _logger = LoggerFactory.getLogger(getQualifiedClassName(DesktopConnection));

        _instance = this;
        _uuid = uuid;
        _onReady = onReady;
        _onError = onError;
        _onClose = onClose;

        _messageHandlers = new Dictionary();

        createWebSocketConnection(host, port);
    }

    private function createWebSocketConnection(host: String, port: String): void{

        _webSocket = new WebSocket("ws://" + host + ":" + port, "*");
        _webSocket.addEventListener(WebSocketEvent.OPEN, onOpen);
        _webSocket.addEventListener(WebSocketEvent.MESSAGE, onMessage);
        _webSocket.addEventListener(WebSocketEvent.CLOSED, onClose);
        _webSocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, onConnectionFail);
        _webSocket.addEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, onAbnormalConnection);
        _webSocket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);

        try{
            _webSocket.connect();
        } catch (error: *){

            if(_onError is Function) _onError(error.message);
        }
        _valid = true;
    }

    private function onOpen(event: WebSocketEvent): void{

        _logger.debug("connection opened...");
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

    private function writeTokenToTheFile(payload: Object): void{

        var file:File = File.desktopDirectory.resolvePath(payload.file);
        var stream:FileStream = new FileStream();
        stream.open(file, FileMode.WRITE);
        stream.writeUTFBytes(payload.token);
        stream.close();
    }

    private function sendAuthorization(): void{

        _state = "auth";
        sendMessage("request-authorization", {

            type: 'file-token',
            uuid: _uuid
        })
    }

    private function onMessage(event: WebSocketEvent): void{

        _logger.debug("RECIEVED: ", event.message.utf8Data);
        var response: Object = JSON.parse(event.message.utf8Data);

        switch(_state){

            case "preAuth":
                if(response.payload.success === false) {

                    if(_onError is Function) _onError(response.payload.reason);
                } else {

                    writeTokenToTheFile(response.payload);
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

        if(method is Function) {
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

        if(_messageId > 0 && ((onMessage is Function) || (onError is Function))){

            _messageHandlers["ack" + _messageId] = {success: onMessage, fail: onError};
        }

        var json: Object = {action: action, payload: payload, messageId: _messageId};
        var message: String = JSON.stringify(json, _jsonFilter);
        _webSocket.sendUTF(message);

        _logger.debug("SENT: ", message);
        return _messageId++;
    }

    private function _jsonFilter(key: String, value: *): * {

        if(!value && value !== false && value !== 0){

            return undefined ;

        } else {

            return value;
        }
    }

    private function onClose(event: WebSocketEvent): void  {
        _logger.debug("onClose", event.toString());
        if (_onClose is Function) _onClose(event.type);
    }

    private function onConnectionFail(event: WebSocketErrorEvent): void{
        _logger.debug("onConnectionFail", event.text);
        if(_onError is Function) _onError(event.errorID + ", " + event.text);
    }

    private function onAbnormalConnection(event: WebSocketErrorEvent): void{
        _logger.debug("onAbnormalConnection", event.text);
        if(_onError is Function) _onError(event.errorID + ", " + event.text);
    }

    private function onIOError(event: IOErrorEvent): void{
        _logger.debug("onIOError", event.errorID, event.text);
        if(_onError is Function) _onError(event.errorID + ", " + event.text);
    }
    
    public function get valid():Boolean {
        return _valid;
    }
}
}
