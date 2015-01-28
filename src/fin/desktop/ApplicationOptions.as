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

    public function ApplicationOptions(uuid: String, name: String = null, url: String = null) {

        this.url = url;
        this.uuid = uuid;
        this.name = name;
        this.mainWindowOptions = new WindowOptions(uuid, name);
    }
}
}
