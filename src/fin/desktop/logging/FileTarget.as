/**
 * Created by richard on 6/10/2017.
 */
package fin.desktop.logging {

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

internal class FileTarget extends AbstractTarget {
    private static var DEFAULT_LOG_PATH : String = "AppData\\Local\\OpenFin\\logs";
    private var fileStream : FileStream;

    public function FileTarget(fileName:String=null) {
        super();
        var logDir: File = File.userDirectory.resolvePath(DEFAULT_LOG_PATH);
        var file: File = logDir.resolvePath( fileName !=null ? fileName : "airadapter.log");
        fileStream = new FileStream();
        fileStream.open (file, FileMode.WRITE);

    }

    override protected function internalLog(message:String, level:Number):void{
        if (fileStream != null) {
            fileStream.writeMultiByte(message + "\n", File.systemCharset);
        }
    }

}
}
