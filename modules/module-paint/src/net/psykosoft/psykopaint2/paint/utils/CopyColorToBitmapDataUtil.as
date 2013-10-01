package net.psykosoft.psykopaint2.paint.utils
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTextureChannels;

	public class CopyColorToBitmapDataUtil
	{
		private static var _copySubTextureChannelsRGB : CopySubTextureChannels;

		public function execute(canvas : CanvasModel) : BitmapData
		{
			_copySubTextureChannelsRGB ||= new CopySubTextureChannels("xyz", "xyz");

			var target : BitmapData = new TrackedBitmapData(canvas.width, canvas.height, false);
			var context3D : Context3D = canvas.stage3D.context3D;
			context3D.setRenderToBackBuffer();
			context3D.clear();
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
			_copySubTextureChannelsRGB.copy(canvas.colorTexture, new Rectangle(0, 0, canvas.usedTextureWidthRatio, canvas.usedTextureHeightRatio), new Rectangle(0, 0, 1, 1), context3D);
			context3D.drawToBitmapData(target);

			return target;
		}

		public function dispose() : void
		{
			if (_copySubTextureChannelsRGB)
				_copySubTextureChannelsRGB.dispose();
		}
	}
}
