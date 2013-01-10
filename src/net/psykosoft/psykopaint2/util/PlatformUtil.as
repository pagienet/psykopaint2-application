package net.psykosoft.psykopaint2.util
{
	import flash.system.Capabilities;

	import net.psykosoft.psykopaint2.config.Settings;

	public class PlatformUtil
	{
		public static function isRunningOnIPad():Boolean {
			var os:String = Capabilities.os;
			trace( "[PlatformUtil] - isRunningOnIPad - OS: " + os );
			return os.indexOf( "iPad" ) != -1;
		}

		public static function isRunningOnRetinaDisplay():Boolean {
			var resX:uint = Capabilities.screenResolutionX;
			var resY:uint = Capabilities.screenResolutionY;
			var dpi:uint = Capabilities.screenDPI;
			trace( "[PlatformUtil] - isRunningOnRetinaDisplay - screen properties - resolution: " + resX + "x" + resY + ", dpi: " + dpi );
			return dpi == Settings.DPI_iPAD_RETINA;
		}
	}
}
