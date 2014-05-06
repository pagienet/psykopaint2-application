package net.psykosoft.psykopaint2.core.views.components.button
{

import flash.display.MovieClip;
import flash.display.Sprite;

public class IconButtonAlt extends IconButtonBase
	{
		// Declared in Flash.
		public var label:Sprite;
		public var icon:MovieClip;

		public function IconButtonAlt() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
		}
	}
}
