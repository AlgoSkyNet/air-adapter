/**
 * Created by haseebriaz on 26/01/2015.
 */
package fin.desktop.transitions {
public class Size {

    private var _width: Number;
    private var _height: Number;
    private var _duration: int;

    public function Size(duration: int, width: Number = undefined, height: Number = undefined) {

        _width = width;
        _height = height;
        _duration = duration;
    }

    public function get width():Number {
        return _width;
    }

    public function get height():Number {
        return _height;
    }

    public function get duration():int {
        return _duration;
    }
}
}
