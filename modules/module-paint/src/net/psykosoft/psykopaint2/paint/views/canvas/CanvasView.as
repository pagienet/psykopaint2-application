package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.utils.getDefinitionByName;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class CanvasView extends ViewBase
	{
		private var _snapshot:Bitmap;
		private var _canvasRect:Rectangle;
		private var _holePuncher:Sprite; // TODO: make shape?
		private var _zeroPoint:Point;
		private var _blur:BlurFilter;
		private var _playedSound:Boolean;

		private const HITCHCOCK_SCALE_FACTOR:Number = 0.1;
		private const HITCHCOCK_OFFSET_FACTOR:Number = 50;

		public function CanvasView() {

			super();

			_zeroPoint = new Point();

			mouseEnabled = mouseChildren = false;

			_snapshot = new Bitmap( new TrackedBitmapData( 1024, 768, true, 0 ) );
			addChild( _snapshot );

			// Hole punchin'
			blendMode = BlendMode.LAYER;
			_holePuncher = new Sprite();
			_holePuncher.graphics.beginFill( 0xFF0000, 1 );
			_holePuncher.graphics.drawRect( 0, 0, 100, 100 );
			_holePuncher.graphics.endFill();
			_holePuncher.blendMode = BlendMode.ERASE;
			addChild( _holePuncher );

			_blur = new BlurFilter( 0, 0, 1 );
			_snapshot.filters = [ _blur ];

			//TODO: 1024? really? What about retina?
			updateCanvasRect( new Rectangle( 0, 0, 1024, 768 ), 1024, false );
		}

		public function updateSnapshot( bmd:BitmapData ):void {
			_snapshot.bitmapData.copyPixels( bmd, bmd.rect, _zeroPoint );
		}

		public function updateCanvasRect( rect:Rectangle, fullWidth:Number, manual:Boolean ):void {

//			trace( this, "update canvas rect: " + rect );
			// Uncomment to debug incoming canvas rect
			/*this.graphics.clear();
			 this.graphics.lineStyle( 1, 0xFF0000, 1 )
			 this.graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
			 this.graphics.endFill();*/

			_canvasRect = rect;

			// Update hole size to fit the canvas.
			_holePuncher.x = _canvasRect.x;
			_holePuncher.y = _canvasRect.y;
			_holePuncher.width = _canvasRect.width;
			_holePuncher.height = _canvasRect.height;

			// Non realistic scaling of the bg.
			var ratio:Number = 1 - _canvasRect.width / fullWidth;
			_snapshot.scaleX = _snapshot.scaleY = 1 + HITCHCOCK_SCALE_FACTOR * ratio;
			_snapshot.x = 1024 / 2 - _snapshot.width / 2;
			_snapshot.y = 768 / 2 - _snapshot.height / 2 - HITCHCOCK_OFFSET_FACTOR * ratio;

			// Comment to mute sound!
			if( manual && !_playedSound ) {
//				playPsychoSound();
				_playedSound = true;
			}
		}

		private function playPsychoSound():void {
			var newClipClass:Class = Class( getDefinitionByName( "psycho" ) );
			var hh:MovieClip = new newClipClass();
			hh.play();
		}

		public function updateBlur( ratio:Number ):void {
			_blur.blurX = _blur.blurY = 16 * ratio;
			_snapshot.filters = [ _blur ];
		}
	}
}
