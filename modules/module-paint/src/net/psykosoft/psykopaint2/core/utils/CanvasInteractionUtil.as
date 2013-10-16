package net.psykosoft.psykopaint2.core.utils
{

	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	public class CanvasInteractionUtil
	{
		public static function canContentsUnderMouseBeIgnored( target:* ):Boolean {

			var onClip:DisplayObjectContainer = target as DisplayObjectContainer;
			if( !onClip ) return false;

			var obj:Array = onClip.getObjectsUnderPoint( new Point( onClip.stage.mouseX, onClip.stage.mouseY ) );
			if( obj.length == 0 ) return true;
			else if( obj.length == 1 ) {
				// Note: add more exceptions here...
				if( obj[ 0 ] is Bitmap ) return true;
				if( obj[ 0 ].parent.name == "woodBgShadow" ) return true;
			}

			return false;
		}
	}
}
