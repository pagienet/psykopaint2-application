package net.psykosoft.psykopaint2.paint.views.crop
{

	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.TouchSheet;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class CropView extends ViewBase
	{
		private var _positioningSheet:TouchSheet;
		private var _baseTextureSize:int;
		private var _sourceMap:BitmapData;
		private var _canvasWidth:int;
		private var _canvasHeight:int;
		private var _easelRect:Rectangle;

		public function CropView() {
			super();
		}

		override protected function onSetup():void {
			_baseTextureSize = _canvasWidth = stage.stageWidth;
			_canvasHeight = stage.stageHeight;
		}

		public function set sourceMap( map:BitmapData ):void {

//			trace( this, "setting source map, rect: " + _easelRect );

			/*this.graphics.beginFill( 0xffffff, 0 );
			this.graphics.drawRect( _easelRect.x, _easelRect.y, _easelRect.width, _easelRect.height );
			this.graphics.endFill();*/

			/*
			graphics.beginFill( 0xFFFFFF, 1.0 );
			graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			graphics.endFill();
			*/
			if( _positioningSheet ) {
				_positioningSheet.dispose();
				removeChild( _positioningSheet );
			}
			if( _sourceMap ) _sourceMap.dispose();
			_sourceMap = map;


			_positioningSheet = new TouchSheet( _sourceMap, Math.max( _easelRect.width/ _sourceMap.width, _easelRect.height / _sourceMap.height ) );
			//_positioningSheet.minimumScale = Math.max( stage.stageWidth / _sourceMap.width, stage.stageHeight / _sourceMap.height );
			//_positioningSheet.limitsRect = new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight );
			_positioningSheet.scrollRect = new Rectangle(0,0,_easelRect.width,_easelRect.height);
			_positioningSheet.x = _easelRect.x;
			_positioningSheet.y = _easelRect.y;
			
			addChildAt( _positioningSheet, 0 );
		
			
		}

		public function renderPreviewToBitmapData():BitmapData 
		{
			var croppedMap:BitmapData = new TrackedBitmapData(stage.stageWidth, stage.stageHeight, false, 0xffffffff );
			croppedMap.draw(_positioningSheet,new Matrix(stage.stageWidth/_easelRect.width,0,0,stage.stageHeight / _easelRect.height),null,"normal",null,true);
			return croppedMap;
			
		}

		public function set easelRect( value:Rectangle ):void {
			trace( this, "easel rect retrieved: " + value );
			_easelRect = value;
		}
		
		override public function enable():void
		{
			super.enable();
			stage.quality = StageQuality.HIGH;
		}
		
		override public function disable():void
		{
			super.disable();
			stage.quality = StageQuality.LOW;
		}
	}
}
