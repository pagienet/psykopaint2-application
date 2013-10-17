package net.psykosoft.psykopaint2.core.utils
{

	import flash.display.Bitmap;
	import flash.display.Stage;
	import flash.geom.Point;

	public class CanvasInteractionUtil
	{
		private static var tmpPoint:Point = new Point();
		
		public static function canContentsUnderMouseBeIgnored( stage:Stage ):Boolean {

//			trace( "CanvasInteractionUtil - canContentsUnderMouseBeIgnored()" );
			tmpPoint.x = stage.mouseX;
			tmpPoint.y = stage.mouseY;
			
			var obj:Array = stage.getObjectsUnderPoint( tmpPoint );
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
