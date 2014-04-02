package net.psykosoft.psykopaint2.crop.views.crop
{

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedRectTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;
	import net.psykosoft.psykopaint2.core.utils.TextureUtils;
	
	

	public class CropView extends ViewBase
	{
		private var _baseTextureSize:int;
		private var _canvasWidth:int;
		private var _canvasHeight:int;
		private var _background : RefCountedRectTexture;
		private var _sourceMap:BitmapData;
		
		public function CropView() {
			super();
		}

		override protected function onSetup():void {
			_baseTextureSize = _canvasWidth = CoreSettings.STAGE_WIDTH;
			_canvasHeight = CoreSettings.STAGE_HEIGHT;
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

				CopyTexture.copy(_background.texture, context3D);
//				CopyTexture.copy(_background.texture, context3D, widthRatio, heightRatio);
				context3D.setDepthTest(true, Context3DCompareMode.LESS);
			}
		}

		public function get background() : RefCountedRectTexture
		{
			return _background;
		}

		public function set background(background : RefCountedRectTexture) : void
		{
			if (_background) _background.dispose();
			_background = background;
		}
		
	}
}
