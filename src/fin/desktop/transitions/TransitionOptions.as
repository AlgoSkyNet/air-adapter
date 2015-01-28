/**
 * Created by haseebriaz on 26/01/2015.
 */
package fin.desktop.transitions {
public class TransitionOptions {

    private var _interrupt: Boolean;

    public function TransitionOptions(interrupt: Boolean = false) {

        _interrupt = interrupt;
    }

    public function get interrupt():Boolean {

        return _interrupt;
    }
}
}
