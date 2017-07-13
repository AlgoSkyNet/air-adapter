/**
 * Created by haseebriaz on 26/01/2015.
 */
package fin.desktop.connection {

/**
 * @private
 */
public class Promise {

    public var _onSuccess: Function;
    public var _onFail: Function;

    private var _payload: Object;
    private var _executed: Boolean;

    public function Promise(onSuccess: Function = null, onFail: Function = null) {

        _onSuccess = onSuccess;
        _onFail = onFail;
    }

    public function success(onSuccess: Function): Promise{

        _onSuccess = onSuccess;
        executeIfGotPayload();
        return this;
    }

    public function fail(onFail: Function): Promise{

        _onFail = onFail;
        executeIfGotPayload();
        return this;
    }

    public function execute(payload: Object): void{

        _payload = payload;

        if(payload.success){

            callMethod(_onSuccess, payload.data);
        } else {

            callMethod((_onFail, payload.type))
        }
    }

    private function callMethod(method: Function, ...args): void{

        if(method is Function) {

            method.apply(null, args);
            _executed = true;
        }
    }

    // this allows for promise to be used in cases when method can switch between synchronus or asynchronous modes
    private function executeIfGotPayload(): void{

        if(_payload && !_executed){

            execute(_payload);
        }
    }
}
}
