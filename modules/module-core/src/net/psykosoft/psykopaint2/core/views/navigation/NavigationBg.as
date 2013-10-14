package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.display.MovieClip;

	public class NavigationBg extends MovieClip
	{
		// These are frame label names, make sure it corresponds in the FLA.
		public static const BG_TYPE_ROPE:String = "rope";
		public static const BG_TYPE_WOOD:String = "wood";
		public static const BG_TYPE_WOOD_LOW:String = "wood1";

		public function NavigationBg() {
			super();
			mouseEnabled = mouseChildren = false;
			stop();
		}

		public function setBgType( type:String ):void {
			gotoAndStop( type );
		}
	}
}
