package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class CanvasView extends ViewBase
	{
		private var _backgroundSnapshot:Bitmap;
		private var _easelRect:Rectangle;
		private var _canvasRect:Rectangle;

		// TODO: snapshot technique is probably low performing, 1st step would be to make it visible only when it should be? is it worth it?

		public function CanvasView() {
			super();
			_easelRect = new Rectangle();
			_canvasRect = new Rectangle( 0, 0, 1024, 768 );
			_backgroundSnapshot = new Bitmap( new TrackedBitmapData( 1024, 768, true, 0 ) );
//			addChild( _backgroundSnapshot );
		}

		public function updateSnapshot( bmd:BitmapData ):void {
			var tempBmd : BitmapData = bmd.clone();
			bmd.dispose();
			trace( this, "update snapshot: " + tempBmd );
			tempBmd.fillRect( _easelRect, 0 );
			// dispose the previously set bitmap data
			_backgroundSnapshot.bitmapData.dispose();
			_backgroundSnapshot.bitmapData = tempBmd;
		}

		public function updateEaselRect( rect:Rectangle ):void {
			_easelRect = rect;
			repositionSnapshot();
		}

		public function updateCanvasRect( rect:Rectangle ):void {
			trace( this, "update canvas rect: " + rect );
			_canvasRect = rect;
			repositionSnapshot();
		}

		private function repositionSnapshot():void {
			trace( this, "repositioning snapshot -----------" );
			var rectRatio:Number = _canvasRect.width / _easelRect.width;
			_backgroundSnapshot.scaleX = _backgroundSnapshot.scaleY = rectRatio;
			_backgroundSnapshot.x = _canvasRect.x - _easelRect.x * rectRatio;
			_backgroundSnapshot.y = _canvasRect.y - _easelRect.y * rectRatio;
		}
	}
}
