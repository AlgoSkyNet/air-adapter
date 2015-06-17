/**
 * Created by haseebriaz on 22/01/2015.
 */
package fin.desktop {
public class ApplicationOptions {

    public var url: String;
    public var uuid: String;
    public var name: String;
    public var mainWindowOptions: WindowOptions;

    internal var _noRegister: Boolean;

    public function ApplicationOptions(uuid: String, url: String = null) {

        this.url = url;
        this.name = this.uuid = uuid;
        this.mainWindowOptions = new WindowOptions(uuid, name);
    }
}
}
