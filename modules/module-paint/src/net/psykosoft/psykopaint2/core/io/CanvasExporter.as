package net.psykosoft.psykopaint2.core.io
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.textures.Texture;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.model.*;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTextureChannels;

	/**
	 * Returns a list of 3 ByteArrays containing data:
	 * 0: painted color layer, in BGRA
	 * 1: normal/specular layer, in BGRA
	 * 2: the source texture, in RGBA!!! (because it's always used primarily as BitmapData)
	 */
	public class CanvasExporter extends EventDispatcher
	{
		private static var _copySubTextureChannelsRGB : CopySubTextureChannels;
		private static var _copySubTextureChannelsA : CopySubTextureChannels;
		private var _canvas : CanvasModel;
		private var _paintingData : PaintingDataVO;

		public function CanvasExporter()
		{
		}

		public function export(canvas : CanvasModel) : void
		{
			if (_canvas) throw "Export already in progress!";

			_canvas = canvas;

			_paintingData = new PaintingDataVO();
			var context3D : Context3D = canvas.stage3D.context3D;
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			var bmp : BitmapData = new BitmapData(canvas.width, canvas.height, false);
			var bmp2 : BitmapData = new BitmapData(canvas.width, canvas.height, false);

			_paintingData.width = canvas.width;
			_paintingData.height = canvas.height;
			_paintingData.colorData = saveLayerWithAlpha(canvas.colorTexture, bmp, bmp2);
			_paintingData.normalSpecularData = saveLayerWithAlpha(canvas.normalSpecularMap, bmp, bmp2);
			_paintingData.sourceBitmapData = saveLayerNoAlpha(canvas.sourceTexture, bmp);

			bmp.dispose();
			bmp2.dispose();

			onComplete();
		}

		private function saveLayerNoAlpha(layer : Texture, workerBitmapData : BitmapData) : ByteArray
		{
			var context3D : Context3D = _canvas.stage3D.context3D;
			var sourceRect : Rectangle = new Rectangle(0, 0, _canvas.usedTextureWidthRatio, _canvas.usedTextureHeightRatio);
			var destRect : Rectangle = new Rectangle(0, 0, 1, 1);

			context3D.setRenderToBackBuffer();
			context3D.clear(0, 0, 0, 0);
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopySubTexture.copy(layer, sourceRect, destRect, context3D);
			context3D.drawToBitmapData(workerBitmapData);
			return workerBitmapData.getPixels(workerBitmapData.rect);
		}

		private function saveLayerWithAlpha(layer : Texture, workerBitmapData1 : BitmapData, workerBitmapData2 : BitmapData) : ByteArray
		{
			var context : Context3D = _canvas.stage3D.context3D;
			var sourceRect : Rectangle = new Rectangle(0, 0, _canvas.usedTextureWidthRatio, _canvas.usedTextureHeightRatio);
			var destRect : Rectangle = new Rectangle(0, 0, 1, 1);

			_copySubTextureChannelsRGB ||= new CopySubTextureChannels("xyz", "xyz");
			_copySubTextureChannelsA ||= new CopySubTextureChannels("w", "z");

			context.setRenderToBackBuffer();
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

			context.clear(0, 0, 0, 1);
			_copySubTextureChannelsRGB.copy(layer, sourceRect, destRect, context);
			context.drawToBitmapData(workerBitmapData1);

			context.clear(0, 0, 0, 1);
			_copySubTextureChannelsA.copy(layer, sourceRect, destRect, context);
			context.drawToBitmapData(workerBitmapData2);

			var rgbData : ByteArray = workerBitmapData1.getPixels(workerBitmapData1.rect);
			var alphaData : ByteArray = workerBitmapData2.getPixels(workerBitmapData2.rect);

			rgbData.position = 0;
			alphaData.position = 0;
			var outputData : ByteArray = new ByteArray();

			var len : int = _canvas.width * _canvas.height;
			for (var i : int = 0; i < len; ++i) {
				var rgb : uint = rgbData.readUnsignedInt();
				var r : uint = rgb & 0x00ff0000;
				var g : uint = rgb & 0x0000ff00;
				var b : uint = rgb & 0x000000ff;
				var a : uint = alphaData.readUnsignedInt() & 0x000000ff;

				outputData.writeUnsignedInt((r >> 8) | (g << 8) | (b << 24) | a);
			}

			rgbData.clear();
			alphaData.clear();

			return outputData;
		}

		private function onComplete() : void
		{
			_canvas = null;
			dispatchEvent(new CanvasExportEvent(CanvasExportEvent.COMPLETE, _paintingData));
		}
	}
}
