package net.psykosoft.psykopaint2.app.view.painting.crop
{

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;

	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.TouchSheet;
	import starling.events.Event;
	import starling.textures.Texture;

	public class CropView extends StarlingViewBase
	{
		private var _positioningSheet:TouchSheet;
		private var _canvasWidth:int;
		private var _canvasHeight:int;
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

			if( _positioningSheet ) _positioningSheet.dispose();

		}

		// -----------------------
		// Private.
		// -----------------------

		private function init():void {

			_baseTextureSize = _canvasWidth = Starling.current.viewPort.width;
			_canvasHeight = Starling.current.viewPort.height;

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		protected function onAddedToStage( event:Event ):void {
			centerCanvas();
		}

		protected function centerCanvas():void {
			if ( !stage ) return;

			if ( _positioningSheet )
			{
				_positioningSheet.x = 0.5 * stage.stageWidth;
				_positioningSheet.y = 0.5 * stage.stageHeight;
				_positioningSheet.limitsRect = new Rectangle( 0,0,stage.stageWidth,stage.stageHeight);
			}
		}

		public function set sourceMap( map:BitmapData ):void {
			if ( _positioningSheet ){
				removeChild(_positioningSheet);
				_positioningSheet.dispose();
			}
			if ( _sourceMap ) _sourceMap.dispose();
			_sourceMap = map;


			var texture:Texture = Texture.fromBitmapData( _sourceMap );
			var image:Image = new Image( texture );
			_positioningSheet = new TouchSheet(image);
			_positioningSheet.scaleX = _positioningSheet.scaleY = _positioningSheet.minimumScale = Math.max(stage.stageWidth /_sourceMap.width, stage.stageHeight/_sourceMap.height);


			addChildAt( _positioningSheet, 0 );
			centerCanvas();
		}

		public function renderPreviewToBitmapData():BitmapData
		{
			var support:RenderSupport = new RenderSupport();
			RenderSupport.clear();
			var nativeWidth:Number = Starling.current.viewPort.width
			var nativeHeight:Number = Starling.current.viewPort.height;

			support.setOrthographicProjection(0,0,nativeWidth, nativeHeight);
			support.applyBlendMode(false);
			support.pushMatrix();

			this.render(support, 1.0);
			support.popMatrix();

			support.finishQuadBatch();

			var croppedMap:BitmapData = new BitmapData(nativeWidth,nativeHeight,false,0xffffffff);
			Starling.context.drawToBitmapData(croppedMap);
			return croppedMap;
		}
	}
}
