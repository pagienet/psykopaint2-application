package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class CanvasView extends ViewBase
	{
		private var _backgroundSnapshot:Bitmap;
		private var _easelRect:Rectangle;
		private var _canvasRect:Rectangle;
		private var _holePuncher:Sprite; // TODO: make shape?

		// TODO: snapshot technique is probably low performing, 1st step would be to make it visible only when it should be? is it worth it?

		public function CanvasView() {

			super();

			_backgroundSnapshot = new Bitmap( new TrackedBitmapData( 1024, 768, true, 0 ) );
			addChild( _backgroundSnapshot );

			// Hole punchin'
			blendMode = BlendMode.LAYER;
			_holePuncher = new Sprite();
			_holePuncher.graphics.beginFill( 0xFF0000, 1 );
			_holePuncher.graphics.drawRect( 0, 0, 100, 100 );
			_holePuncher.graphics.endFill();
			_holePuncher.blendMode = BlendMode.ERASE;
			addChild( _holePuncher );

			_easelRect = new Rectangle();

			//TODO: 1024? really? What about retina?
			_canvasRect = new Rectangle( 0, 0, 1024, 768 );
			mouseEnabled = mouseChildren = false;
		}

		public function updateSnapshot( bmd:BitmapData ):void {

			_backgroundSnapshot.bitmapData.copyPixels( bmd, bmd.rect, new Point() );
//			_backgroundSnapshot.bitmapData.fillRect( _easelRect, 0 );

			//Replace this code which seemed strange
			/*
			 var tempBmd : BitmapData = bmd.clone();
			 bmd.dispose();
			 trace( this, "update snapshot: " + tempBmd + ", rect: " + _easelRect );
			 tempBmd.fillRect( _easelRect, 0 );
			 // dispose the previously set bitmap data
			 _backgroundSnapshot.bitmapData.dispose();
			 _backgroundSnapshot.bitmapData = tempBmd;
			 */
		}

		public function updateEaselRect( rect:Rectangle ):void {
			trace( this, "update easel rect: " + rect );
			_easelRect = rect;
			_holePuncher.x = _easelRect.x;
			_holePuncher.y = _easelRect.y;
			_holePuncher.width = _easelRect.width;
			_holePuncher.height = _easelRect.height;
			repositionSnapshot();
		}

		public function updateCanvasRect( rect:Rectangle ):void {

			trace( this, "update canvas rect: " + rect );
			// Uncomment to debug incoming canvas rect
			/*this.graphics.clear();
			 this.graphics.lineStyle( 1, 0xFF0000, 1 )
			 this.graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
			 this.graphics.endFill();*/

			// TODO: the incoming rect seems to be incorrect in x and y, and the renderer doesn't seem to care about this, since it centers it on the canvas viewport anyway
			// Need to use the correct x and y

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
