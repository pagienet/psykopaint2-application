package net.psykosoft.psykopaint2.paint.views.crop
{

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.TouchSheet;

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

			// TODO: implement proper easel rect - info already here
			this.graphics.beginFill( 0xFF0000, 0.25 );
			this.graphics.drawRect( _easelRect.x, _easelRect.y, _easelRect.width, _easelRect.height );
			this.graphics.endFill();

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


			_positioningSheet = new TouchSheet( _sourceMap, Math.max( 482/ _sourceMap.width, 364 / _sourceMap.height ) );
			//_positioningSheet.minimumScale = Math.max( stage.stageWidth / _sourceMap.width, stage.stageHeight / _sourceMap.height );
			//_positioningSheet.limitsRect = new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight );
			_positioningSheet.scrollRect = new Rectangle(0,0,482,364);
			_positioningSheet.x = 270;
			_positioningSheet.y = 81;
			
			addChildAt( _positioningSheet, 0 );
		
			
		}

		public function renderPreviewToBitmapData():BitmapData 
		{
			var croppedMap:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0xffffffff );
			croppedMap.draw(_positioningSheet,new Matrix(stage.stageWidth/482,0,0,stage.stageHeight / 364),null,"normal",null,true);
			return croppedMap;
			
		}

		public function set easelRect( value:Rectangle ):void {
			trace( this, "easel rect retrieved: " + value );
			_easelRect = value;
		}
	}
}
