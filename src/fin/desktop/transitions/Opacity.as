/**
 * Created by haseebriaz on 26/01/2015.
 */
package fin.desktop.transitions {

public class Opacity {

    private var _value: Number;
    private var _duration: int;

    public function Opacity(duration: int, value: Number) {

        _value = value;
        _duration = duration;
    }

    public function get opacity(): Number{

        return _value;
    }

    public function get duration():int {
        return _duration;
    }
}
}
