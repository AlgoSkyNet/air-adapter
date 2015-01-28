/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {
public class WindowOptions {

    public var maxWidth: Number;
    public var launchExternal: String;
    public var alphaMask: Object;
    public var defaultHeight: Number;
    public var defaultCentered: Boolean;
    public var autoShow: Boolean;
    public var defaultTop: Number;
    public var defaultLeft: Number;
    public var resizeRegion: Object;
    public var draggable: Boolean;
    public var name: String;
    public var hideWhileChildrenVisible: Boolean;
    public var hideOnClose: Boolean;
    public var hideOnBlur: Boolean;
    public var resizable: Boolean;
    public var opacity: Number;
    public var contextMenu: Boolean;
    public var minWidth: Number;
    public var frame: Boolean;
    public var showTaskbarIcon: Boolean;
    public var uuid: String;
    public var defaultWidth: Number;
    public var cornerRounding: Object;
    public var state: String;
    public var alwaysOnTop: Boolean;
    public var url: String;
    public var alwaysOnBottom: Boolean;
    public var shadow: Boolean;
    public var minHeight: Number;
    public var exitOnClose: Boolean;
    public var minimizable: Boolean;
    public var maxHeight: Number;
    public var maximizable: Boolean;

    public function WindowOptions(uuid: String = null, name: String = null) {

        this.uuid = uuid;
        this.name = name;
    }
}
}
