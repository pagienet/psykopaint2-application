package net.psykosoft.psykopaint2.paint.views.crop
{

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.TouchSheet;

	public class CropView extends ViewBase
	{
		// TODO: commented by li, we don't use starling anymore
		private var _positioningSheet:TouchSheet;
		private var _baseTextureSize:int;
		private var _sourceMap:BitmapData;
		private var _canvasWidth:int;
		private var _canvasHeight:int;

		public function CropView() {
			super();
		}

		override protected function onSetup():void {
			// TODO: commented by li, we don't use starling anymore
			_baseTextureSize = _canvasWidth = stage.stageWidth;
			_canvasHeight = stage.stageHeight;
			centerCanvas();
		}

		protected function centerCanvas():void {
			if( !stage ) return;

			if( _positioningSheet ) {
				_positioningSheet.x = 0.5 * stage.stageWidth;
				_positioningSheet.y = 0.5 * stage.stageHeight;
				_positioningSheet.limitsRect = new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight );
			}
		}

		public function set sourceMap( map:BitmapData ):void {
			
			
			graphics.beginFill( 0xFFFFFF, 1.0 );
			graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			graphics.endFill();
			
			if( _positioningSheet ) {
				_positioningSheet.dispose();
				removeChild( _positioningSheet );
			}
			if( _sourceMap ) _sourceMap.dispose();
			_sourceMap = map;


			_positioningSheet = new TouchSheet( _sourceMap );
			_positioningSheet.minimumScale = Math.max( stage.stageWidth / _sourceMap.width, stage.stageHeight / _sourceMap.height );


			addChildAt( _positioningSheet, 0 );
			centerCanvas();
			
		}

		public function renderPreviewToBitmapData():BitmapData 
		{
			var croppedMap:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0xffffffff );
			croppedMap.draw(this,null,null,"normal",null,true);
			return croppedMap;
			return null;
		}
	}
}
