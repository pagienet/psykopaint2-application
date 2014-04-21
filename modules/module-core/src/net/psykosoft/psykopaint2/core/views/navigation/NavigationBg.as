package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class NavigationBg extends MovieClip
	{
		// These are frame label names, make sure it corresponds in the FLA.
		public static const BG_TYPE_ROPE:String = "rope";
		public static const BG_TYPE_WOOD:String = "wood";
		public static const BG_TYPE_WOOD_LOW:String = "wood1";
		private var _type:String;
		
		public var bg:Sprite;

		public function NavigationBg() {
			super();
			mouseEnabled = mouseChildren = false;
			stop();
		}

		public function getBgType():String
		{
			return _type;
		}

		public function setBgType( type:String ):void {
			_type = type;
			gotoAndStop( type );
			/*if ( type == BG_TYPE_WOOD || type == BG_TYPE_WOOD_LOW)
			{
				((getChildAt(0) as Sprite).getChildByName("woodBgShadow") as Sprite).mouseEnabled = false;
			}*/
		}
	}
}
