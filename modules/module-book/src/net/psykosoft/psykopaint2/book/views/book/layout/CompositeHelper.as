package net.psykosoft.psykopaint2.book.views.book.layout
{
	/*helper class for layout compositing routines*/

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;

 	public class CompositeHelper
 	{
 		private const DEGREES_TO_RADIANS:Number = Math.PI/180;

 		private var _destPt:Point;

 		function CompositeHelper(){}

 		public function insert(insertSource:BitmapData, destSource:BitmapData, insertRect:Rectangle, rotation:Number = 0, disposeInsert:Boolean = false, offsetRotationX:Number = 0, offsetRotationY:Number = 0):BitmapData
		{
			var w:Number = insertRect.width/insertSource.width;
			var h:Number = insertRect.height/insertSource.height;
			var t:Matrix = new Matrix();

			var arbX:Number = (insertRect.width*.5)+offsetRotationX;
			var arbY:Number = (insertRect.height*.5)+offsetRotationY;

			t.scale(w, h);
			t.translate(-arbX, -arbY );
			t.rotate(rotation*DEGREES_TO_RADIANS);
			t.translate(insertRect.x+arbX, insertRect.y+arbY );

			destSource.draw(insertSource, t, null, "normal", null, true);
			
			if(disposeInsert) insertSource.dispose();
			
			return destSource;
		}

 	}
 }