package net.psykosoft.psykopaint2.core.io
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
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
		private var _stage : int;
		private var _ticker : Sprite;
		private var _workerBitmapData : BitmapData;
		private var _rgbData : ByteArray;
		private var _alphaData : ByteArray;
		private var _context3D : Context3D;
		private var _sourceRect : Rectangle;
		private var _destRect : Rectangle;

		public function CanvasExporter()
		{
		}

		public function export(canvas : CanvasModel) : void
		{
			if (_canvas) throw "Export already in progress!";
			_canvas = canvas;

			init();

			_paintingData = new PaintingDataVO();

			_workerBitmapData = new BitmapData(canvas.width, canvas.height, false);

			_paintingData.width = canvas.width;
			_paintingData.height = canvas.height;

			saveColorData();
			saveNormalData();
			saveSourceData();

			onComplete();
		}

		private function init() : void
		{
			_context3D = _canvas.stage3D.context3D;

			_sourceRect = new Rectangle(0, 0, _canvas.usedTextureWidthRatio, _canvas.usedTextureHeightRatio);
			_destRect = new Rectangle(0, 0, 1, 1);


			_ticker = new Sprite();
			_ticker.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			_copySubTextureChannelsRGB ||= new CopySubTextureChannels("xyz", "xyz");
			_copySubTextureChannelsA ||= new CopySubTextureChannels("w", "z");

			_stage = 0;
		}

		private function saveColorRGB() : void
		{

		}

		private function saveColorAlpha() : void
		{

		}

		private function saveColorData() : void
		{
			_rgbData = extractRGBData(_canvas.colorTexture, _copySubTextureChannelsRGB);
			_alphaData = extractRGBData(_canvas.colorTexture, _copySubTextureChannelsA);

			_paintingData.colorData = mergeRGBAData();
		}

		private function saveNormalData() : void
		{
			_rgbData = extractRGBData(_canvas.normalSpecularMap, _copySubTextureChannelsRGB);
			_alphaData = extractRGBData(_canvas.normalSpecularMap, _copySubTextureChannelsA);

			_paintingData.normalSpecularData = mergeRGBAData();
		}

		private function saveSourceData() : void
		{
			_paintingData.sourceBitmapData = saveLayerNoAlpha(_canvas.sourceTexture);
		}

		private function onEnterFrame(event : Event) : void
		{

		}

		private function saveLayerNoAlpha(layer : Texture) : ByteArray
		{
			var context3D : Context3D = _canvas.stage3D.context3D;

			context3D.setRenderToBackBuffer();
			context3D.clear(0, 0, 0, 0);
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopySubTexture.copy(layer, _sourceRect, _destRect, context3D);
			context3D.drawToBitmapData(_workerBitmapData);
			return _workerBitmapData.getPixels(_workerBitmapData.rect);
		}

		private function mergeRGBAData() : ByteArray
		{
			_rgbData.position = 0;
			_alphaData.position = 0;
			var outputData : ByteArray = new ByteArray();

			var len : int = _canvas.width * _canvas.height;
			for (var i : int = 0; i < len; ++i) {
				var rgb : uint = _rgbData.readUnsignedInt();
				var r : uint = rgb & 0x00ff0000;
				var g : uint = rgb & 0x0000ff00;
				var b : uint = rgb & 0x000000ff;
				var a : uint = _alphaData.readUnsignedInt() & 0x000000ff;

				outputData.writeUnsignedInt((r >> 8) | (g << 8) | (b << 24) | a);
			}

			_rgbData.clear();
			_alphaData.clear();
			return outputData;
		}

		private function extractRGBData(layer : Texture, copier : CopySubTextureChannels) : ByteArray
		{
			_context3D.setRenderToBackBuffer();
			_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

			_context3D.clear(0, 0, 0, 1);
			copier.copy(layer, _sourceRect, _destRect, _context3D);
			_context3D.drawToBitmapData(_workerBitmapData);

			return _workerBitmapData.getPixels(_workerBitmapData.rect);
		}

		private function onComplete() : void
		{
			_ticker.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_ticker = null;
			_canvas = null;
			_context3D = null;
			_sourceRect = null;
			_destRect = null;
			_workerBitmapData.dispose();
			_workerBitmapData = null;
			dispatchEvent(new CanvasExportEvent(CanvasExportEvent.COMPLETE, _paintingData));
		}
	}
}
