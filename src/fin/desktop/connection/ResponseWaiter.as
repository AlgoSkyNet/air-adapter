/**
 * Created by haseebriaz on 23/01/2015.
 */
package fin.desktop.connection {

/**
 * @private
 */
public class ResponseWaiter {

    private var _callback: Function;
    private var _args: Array;

    public function ResponseWaiter(callback: Function, ...args) {

        _callback = callback;
        _args = args;
    }

    public function onResponse(data: Object): void{

        if(_callback.length > _args.length)_args.push(data);
        _callback.apply(null, _args);
    }
}
}
