/**
 * Created by haseebriaz on 26/01/2015.
 */
package fin.desktop.transitions {
public class Transition {

    public var opacity: Opacity;
    public var size: Size;
    public var position: Position;

    public function Transition(opacity: Opacity = null, size: Size = null, position: Position = null) {

        this.opacity = opacity;
        this.size = size;
        this.position = position;
    }

    public static function opacity(duration: int, value: Number): Opacity{

        return new Opacity(duration, value);
    }

    public static function size(duration: int, width: Number = undefined, height: Number = undefined): Size{

        return new Size(duration, width, height);
    }

    public static function position(duration: int, left: Number = undefined, top: Number = undefined): Position{

        return new Position(duration, left, top);
    }
}
}
