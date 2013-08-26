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
		
		//0 means lowest performance, higher value is higer performance - based on model not on actual measures
		// at the moment:
		// 0 for ipad 1
		// 1 ipad 2 and 3
		// 2 desktop, ipad mini, ipad 4
		//TODO: android and iphone
		//for internal model numbers: http://theiphonewiki.com/wiki/IPad 
		//http://theiphonewiki.com/wiki/IPad_mini
		public static function performanceRating():int
		{
			if ( !isRunningOnIPad()) return 2;
			
			var os:String = Capabilities.os.toLowerCase();
			if ( os.indexOf("ipad1") != -1 ) return 0;
			
			if ( os.indexOf("ipad3,1") != -1 || 
				 os.indexOf("ipad3,2") != -1 ||  	
				 os.indexOf("ipad3,3") != -1 || 
				 os.indexOf("ipad2,1") != -1 || 
				 os.indexOf("ipad2,2") != -1  || 
				 os.indexOf("ipad2,3") != -1  || 
				 os.indexOf("ipad2,4") != -1) return 1;
			
			//mini 1 is 2,5/2,6/2,7
			
			return 2;
		}
	}
}
