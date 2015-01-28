/**
 * Created by haseebriaz on 26/01/2015.
 */
package fin.desktop.transitions {
public class Position{

    private var _left: Number;
    private var _top: Number;
    private var _duration: int;

    public function Position(duration: int, left: Number = undefined, top: Number = undefined)  {

        _left = left;
        _top = top;
        _duration = duration;
    }

    public function get left():Number {
        return _left;
    }

    public function get top():Number {
        return _top;
    }

    public function get duration():int {
        return _duration;
    }
}
}
