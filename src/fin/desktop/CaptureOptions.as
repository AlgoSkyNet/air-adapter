/**
 * Created by wenjun on 6/27/2017.
 */
package fin.desktop {
public class CaptureOptions {
    private var _borderTop: int;
    private var _borderBottom: int;
    private var _borderLeft: int;
    private var _borderRight: int;

    public function CaptureOptions() {
    }

    public function get borderTop():int {
        return _borderTop;
    }

    public function set borderTop(value:int):void {
        _borderTop = value;
    }

    public function get borderBottom():int {
        return _borderBottom;
    }

    public function set borderBottom(value:int):void {
        _borderBottom = value;
    }

    public function get borderLeft():int {
        return _borderLeft;
    }

    public function set borderLeft(value:int):void {
        _borderLeft = value;
    }

    public function get borderRight():int {
        return _borderRight;
    }

    public function set borderRight(value:int):void {
        _borderRight = value;
    }
}
}
