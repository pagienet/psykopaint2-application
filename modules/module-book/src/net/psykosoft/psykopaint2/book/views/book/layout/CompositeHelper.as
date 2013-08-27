package net.psykosoft.psykopaint2.book.views.book.layout
{
	/*helper class for layout compositing routines*/

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	 
 	public class CompositeHelper
 	{
 		private const DEGREES_TO_RADIANS:Number = Math.PI/180;

 		private var _t:Matrix;
 		private var _lastWidth:Number = 0;
		private var _lastHeight:Number = 0;
 
 		function CompositeHelper(){}

 		public function insert(insertSource:BitmapData, destSource:BitmapData, insertRect:Rectangle, rotation:Number = 0, disposeInsert:Boolean = false, keepRatio:Boolean = false, offsetRotationX:Number = 0, offsetRotationY:Number = 0, offsetX:Number = 0, offsetY:Number = 0):BitmapData
		{
			var w:Number = insertRect.width/insertSource.width;
			var h:Number = insertRect.height/insertSource.height;

			var cx:Number = 0;
			var cy:Number = 0;

			if(!_t) {
				_t = new Matrix();
			} else {
				_t.identity();
			}

			var arbX:Number = (insertRect.width*.5)+offsetRotationX;
			var arbY:Number = (insertRect.height*.5)+offsetRotationY;
 
			if(keepRatio){
				
				if(w>h){
					
					if(insertSource.width < insertRect.width){
						w = Math.min(insertRect.width, insertSource.width) / Math.max(insertRect.width, insertSource.width);
						h = w;

					} else {
						h = Math.min(insertRect.height,insertSource.height) / Math.max(insertRect.height,insertSource.height);
						w = h;
					}

				} else {
 
					if(insertSource.width > insertRect.width){
						w = Math.min(insertRect.width, insertSource.width) / Math.max(insertRect.width, insertSource.width);
						h = w;
 
					} else {
						h = Math.min(insertRect.height,insertSource.height) / Math.max(insertRect.height,insertSource.height);
						w = h;
					}
  
				}

				cx = (insertRect.width - (insertSource.width * h) )*.5;
				cy = (insertRect.height - (insertSource.height * h) )*.5;
 
			}
 
			cx += offsetX;
			cy += offsetY;

			_lastWidth = insertSource.width*w;
			_lastHeight = insertSource.height*h;
			
			_t.scale(w, h);
			_t.translate(-arbX+cx, -arbY+cy );
			_t.rotate(rotation*DEGREES_TO_RADIANS);
			_t.translate(insertRect.x+arbX , insertRect.y+arbY);
 

			destSource.draw(insertSource, _t, null, "normal", null, true);

			if(disposeInsert) insertSource.dispose();

			return destSource;
		}
 
		public function get lastWidth():Number
		{
			return _lastWidth;
		}

		public function get lastHeight():Number
		{
			return _lastHeight;
		}

 	}
 }