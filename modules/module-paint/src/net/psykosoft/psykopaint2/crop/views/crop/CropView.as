package net.psykosoft.psykopaint2.crop.views.crop
{

	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.TouchSheet;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.utils.TextureUtils;
	
	import org.gestouch.events.GestureEvent;

	public class CropView extends ViewBase
	{
	//	private var _positioningSheet:TouchSheet;
		private var _baseTextureSize:int;
		private var _canvasWidth:int;
		private var _canvasHeight:int;
		private var _easelRect:Rectangle;
		private var _background : RefCountedTexture;
		private var _sourceMap:BitmapData;
		
		public function CropView() {
			super();
		}

		override protected function onSetup():void {
			_baseTextureSize = _canvasWidth = CoreSettings.STAGE_WIDTH;
			_canvasHeight = CoreSettings.STAGE_HEIGHT;
		}

		public function setSourceMap( map:BitmapData, orientation:int  ):void {
			_sourceMap = map;
		}

		public function getCroppedImage():BitmapData
		{
			var croppedMap:BitmapData = new TrackedBitmapData(stage.stageWidth, stage.stageHeight, false, 0xffffffff );
			//croppedMap.draw(_sourceMap,new Matrix(stage.stageWidth/_easelRect.width,0,0,stage.stageHeight / _easelRect.height),null,"normal",null,true);
			var scale:Number = stage.stageWidth/_sourceMap.width;
			croppedMap.draw(_sourceMap,new Matrix(scale,0,0,scale,0,(stage.stageHeight - _sourceMap.height * scale) * 0.5),null,"normal",null,true);
			return croppedMap;
			
		}

		public function set easelRect( value:Rectangle ):void {
			_easelRect = value.clone();
		}
		
		override public function enable():void
		{
			super.enable();
		}
		
		override public function disable():void
		{
			super.disable();
		}

		public function render(context3D : Context3D):void
		{
			if (_background) {
				context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
				context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);

				var widthRatio : Number = CoreSettings.STAGE_WIDTH/TextureUtils.getBestPowerOf2(CoreSettings.STAGE_WIDTH);
				var heightRatio : Number = CoreSettings.STAGE_HEIGHT/TextureUtils.getBestPowerOf2(CoreSettings.STAGE_HEIGHT);
				CopySubTexture.copy(_background.texture, new Rectangle(0, 0, widthRatio, heightRatio), new Rectangle(0, 0, 1, 1), context3D);
//				CopyTexture.copy(_background.texture, context3D, widthRatio, heightRatio);
				context3D.setDepthTest(true, Context3DCompareMode.LESS);
			}
		}

		public function get background() : RefCountedTexture
		{
			return _background;
		}

		public function set background(background : RefCountedTexture) : void
		{
			if (_background) _background.dispose();
			_background = background;
		}
		
	}
}
