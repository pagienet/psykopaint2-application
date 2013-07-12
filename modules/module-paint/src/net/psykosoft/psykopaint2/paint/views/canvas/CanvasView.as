package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class CanvasView extends ViewBase
	{
		private var _backgroundSnapshot:Bitmap;
		private var _canvasRect:Rectangle;
		private var _holePuncher:Sprite; // TODO: make shape?

		// TODO: snapshot technique is probably low performing, 1st step would be to make it visible only when it should be? is it worth it?

		public function CanvasView() {

			super();

			mouseEnabled = mouseChildren = false;

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

			//TODO: 1024? really? What about retina?
			updateCanvasRect( new Rectangle( 0, 0, 1024, 768 ) );
		}

		public function updateSnapshot( bmd:BitmapData ):void {
			_backgroundSnapshot.bitmapData.copyPixels( bmd, bmd.rect, new Point() );
		}

		public function updateCanvasRect( rect:Rectangle ):void {

//			trace( this, "update canvas rect: " + rect );
			// Uncomment to debug incoming canvas rect
			/*this.graphics.clear();
			 this.graphics.lineStyle( 1, 0xFF0000, 1 )
			 this.graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
			 this.graphics.endFill();*/

			_canvasRect = rect;

			_holePuncher.x = _canvasRect.x;
			_holePuncher.y = _canvasRect.y;
			_holePuncher.width = _canvasRect.width;
			_holePuncher.height = _canvasRect.height;
		}
	}
}
