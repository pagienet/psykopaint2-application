package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.display.Sprite;

	public class NavigationBg extends Sprite
	{
		// Declared in Flash.
		public var wire:Sprite;
		public var wood:Sprite;

		public static const BG_TYPE_ROPE:uint = 0;
		public static const BG_TYPE_WOOD:uint = 1;

		public function NavigationBg() {
			super();
			mouseEnabled = mouseChildren = false;
		}

		public function setBgType( type:uint ):void {
			if( type == NavigationBg.BG_TYPE_ROPE ) {
				wood.visible = false;
				wire.visible = true;
			}
			else {
				wood.visible = true;
				wire.visible = false;
			}
		}
	}
}
