package net.psykosoft.psykopaint2.base.utils.misc
{

	import flash.system.Capabilities;

	public class PlatformUtil
	{
		public static function isRunningOnIPad():Boolean {
			var os:String = Capabilities.os;
			return os.toLowerCase().indexOf( "ipad" ) != -1;
		}

		public static function isRunningOnDisplayWithDpi( displayDpi:uint ):Boolean {
			var dpi:uint = Capabilities.screenDPI;
			return dpi == displayDpi;
		}
	}
}
