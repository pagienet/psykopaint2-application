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
			if( obj.length == 1 ) {
//				trace( "CanvasInteractionUtil - canContentsUnderMouseBeIgnored - ", "looking for exceptions..." );
				// Note: add more exceptions here...
				if( obj[ 0 ] is Bitmap ) {
//					trace( "bitmap" );
					return true;
				}
				if( obj[ 0 ].parent.name == "woodBgShadow" ) {
//					trace( "woodBgShadow" );
					return true;
				}
			}

			return false;
		}
	}
}
