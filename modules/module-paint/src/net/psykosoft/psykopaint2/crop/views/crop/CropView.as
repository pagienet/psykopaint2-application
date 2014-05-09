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
	}
}
