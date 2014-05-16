package net.psykosoft.psykopaint2.core.managers.social
{
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.events.EventDispatcher;




	public class SocialSharingManager extends EventDispatcher
	{
		public static const FACEBOOK_APP_ID:String = "503384473059408";
	
		
		
		[PostConstruct]
		public function init():void {
			
			
			// Check support.
			if( !GoViral.isSupported() ) {
				trace( "SocialSharingManager: GoViral is not supported on this platform." );
				return;
			}
	
			// Init.
			GoViral.create();
	//		trace(describeType(GoViral.goViral)); // Traces methods and properties of GoViral.
			
			// Init facebook.
			if( GoViral.goViral.isFacebookSupported() ) {
				GoViral.goViral.initFacebook( FACEBOOK_APP_ID, "" );
			}
			else {
				trace( "SocialSharingManager: Warning: Facebook not supported on this device." );
			}
		}
	
		public function get goViral():GoViral {
			return GoViral.goViral;
		}
	
		// See SharerBase implementations to see how each kind of sharing works.
	}
}