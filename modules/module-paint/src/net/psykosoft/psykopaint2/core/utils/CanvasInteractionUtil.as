package net.psykosoft.psykopaint2.core.utils
{

	import flash.display.Bitmap;
	import flash.display.Stage;
	import flash.geom.Point;

	public class CanvasInteractionUtil
	{
		public static function canContentsUnderMouseBeIgnored( stage:Stage ):Boolean {

//			trace( "CanvasInteractionUtil - canContentsUnderMouseBeIgnored()" );

			var obj:Array = stage.getObjectsUnderPoint( new Point( stage.mouseX, stage.mouseY ) );
//			trace( "looking for exceptions - objs under mouse: " + obj.length + ", " + obj );
			if( obj.length == 1 ) {
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
