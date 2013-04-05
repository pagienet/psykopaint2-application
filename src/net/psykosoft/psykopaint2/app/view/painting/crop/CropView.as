package net.psykosoft.psykopaint2.app.view.painting.crop
{

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;
	import net.psykosoft.utils.BitmapDataUtils;

	import starling.display.Image;
	import starling.display.TouchSheet;
	import starling.events.Event;
	import starling.textures.Texture;

	public class CropView extends StarlingViewBase
	{
		private var _positioningSheet:TouchSheet;
		private var _frameTexture:Texture;
		private var _frameImage:Image;
		private var _canvasWidth:int;
		private var _canvasHeight:int;
		private var _cropFrameScale:Number;
		private var _baseTextureSize:int;
		private var _sourceMap:BitmapData;

		public function CropView() {
			super();
			init();
		}

		// -----------------------
		// Overrides.
		// -----------------------

		override protected function onEnabled():void {
			// Todo: must the view do something on enabled/disabled?
		}

		override protected function onDisabled():void {
			// Todo: must the view do something on enabled/disabled?
		}

		override protected function onDispose():void {

			if( _sourceMap ) {
				_sourceMap.dispose();
				_sourceMap = null;
			}

			if( _frameTexture ) {
				_frameTexture.dispose();
				_frameTexture = null;
			}

			if( _frameImage ) {
				removeChild( _frameImage );
				_frameImage.dispose();
				_frameImage = null;
			}

			if( _positioningSheet ) _positioningSheet.dispose();

		}

		// -----------------------
		// Private.
		// -----------------------

		private function init():void {
			//TODO: replace these with values passed in or a global constant
			_canvasWidth = 1024;
			_canvasHeight = 768;

			_baseTextureSize = 1024;
			_cropFrameScale = 0.5;

			var frameMap:BitmapData = new BitmapData( 1024 * _cropFrameScale, 768 * _cropFrameScale, true, 0xff000000 );
			frameMap.fillRect( new Rectangle( 1, 1, frameMap.width - 2, frameMap.height - 2 ), 0 );

			_frameTexture = Texture.fromBitmapData( frameMap );
			frameMap.dispose();
			_frameImage = new Image( _frameTexture );
			_frameImage.touchable = false;

			addChild( _frameImage );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		protected function onAddedToStage( event:Event ):void {
			centerCanvas();
		}

		protected function centerCanvas():void {
			if( !stage ) return;

			if( _frameImage ) {
				_frameImage.x = 0.5 * ( stage.stageWidth - _frameImage.width );
				_frameImage.y = 0.5 * ( stage.stageHeight - _frameImage.height);
			}

			if( _positioningSheet ) {
				_positioningSheet.x = 0.5 * stage.stageWidth;
				_positioningSheet.y = 0.5 * stage.stageHeight;
				_positioningSheet.limitsRect = new Rectangle( 0.5 * stage.stageWidth - _frameImage.width * 0.5,
						0.5 * stage.stageHeight - _frameImage.height * 0.5,
						_frameImage.width, _frameImage.height );
			}
		}

		public function set sourceMap( map:BitmapData ):void {
			if( _positioningSheet ) {
				removeChild( _positioningSheet );
				_positioningSheet.dispose();
			}
			if( _sourceMap ) _sourceMap.dispose();
			_sourceMap = BitmapDataUtils.getLegalBitmapData( map );


			var texture:Texture = Texture.fromBitmapData( _sourceMap );
			var image:Image = new Image( texture );
			_positioningSheet = new TouchSheet( image );
			_positioningSheet.scaleX = _positioningSheet.scaleY = _positioningSheet.minimumScale = Math.max( _frameImage.width / _positioningSheet.width, _frameImage.height / _positioningSheet.height );
//			_positioningSheet.minimumRotation = 0;
//			_positioningSheet.maximumRotation = 0;

			addChildAt( _positioningSheet, 0 );
			centerCanvas();

		}

		public function get cropMatrix():Matrix {
			var m:Matrix =_positioningSheet.transformationMatrix;
			m.translate(-0.5 * stage.stageWidth,-0.5 * stage.stageHeight);
			m.scale( 1 / _cropFrameScale,1 / _cropFrameScale );
			m.translate(0.5 * _canvasWidth,0.5 * _canvasHeight);
			return m;
		}
	}
}
