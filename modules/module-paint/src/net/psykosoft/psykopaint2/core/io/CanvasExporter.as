package net.psykosoft.psykopaint2.core.io
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	import net.psykosoft.psykopaint2.core.model.*;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTextureChannels;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;

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
		private var _exportingStage : int;
		private var _workerBitmapData : BitmapData;
		private var _rgbData : ByteArray;
		private var _alphaData : ByteArray;
		private var _context3D : Context3D;
		private var _sourceRect : Rectangle;
		private var _destRect : Rectangle;
		private var _stage:Stage;

		private var _exportingStages : Array;
		private var _time:uint;

		public function CanvasExporter( stage:Stage )
		{
			_stage = stage;

			_exportingStages = [
				saveColorRGB,
				saveColorAlpha,
				mergeColorData,

				extractNormalsColor,
				extractNormalsAlpha,
				mergeNormalData,

				saveSourceData
			];

			_copySubTextureChannelsRGB ||= new CopySubTextureChannels("xyz", "xyz");
			_copySubTextureChannelsA ||= new CopySubTextureChannels("w", "z");
		}



		public function export(canvas : CanvasModel) : void
		{
			if (_canvas) throw "Export already in progress!";
			_canvas = canvas;

			init();

			_exportingStage = 0;
			executeStage();
		}

		private function init() : void
		{
			_context3D = _canvas.stage3D.context3D;

			_sourceRect = new Rectangle(0, 0, _canvas.usedTextureWidthRatio, _canvas.usedTextureHeightRatio);
			_destRect = new Rectangle(0, 0, 1, 1);

			_paintingData = new PaintingDataVO();

			_workerBitmapData = new TrackedBitmapData(_canvas.width, _canvas.height, false);

			_paintingData.width = _canvas.width;
			_paintingData.height = _canvas.height;

			_paintingData.normalSpecularOriginal = _canvas.getNormalSpecularOriginal();
			_paintingData.colorBackgroundOriginal = _canvas.getColorBackgroundOriginal();

			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(event : Event) : void
		{
			_exportingStage++;
			ConsoleView.instance.log( this, "onEnterFrame - stage: " + _exportingStage + "/" + _exportingStages.length );
			if ( _exportingStage < _exportingStages.length )
				executeStage();
			else
				onComplete();
		}

		private function executeStage() : void
		{
			ConsoleView.instance.log( this, "-executeStage-" );
			_exportingStages[_exportingStage]();
			dispatchEvent(new CanvasExportEvent(CanvasExportEvent.PROGRESS, _paintingData, _exportingStage, _exportingStages.length));
		}

	// the stages:
		private function saveColorRGB() : void
		{
			ConsoleView.instance.log( this, "saveColorRGB stage..." );
			_rgbData = extractChannels(_canvas.colorTexture, _copySubTextureChannelsRGB);
		}

		private function saveColorAlpha() : void
		{
			ConsoleView.instance.log( this, "saveColorAlpha stage..." );
			_alphaData = extractChannels(_canvas.colorTexture, _copySubTextureChannelsA);
		}

		private function mergeColorData() : void
		{
			ConsoleView.instance.log( this, "mergeColorData stage..." );
			_paintingData.colorData = mergeRGBAData();
		}

		private function extractNormalsColor() : void
		{
			ConsoleView.instance.log( this, "extractNormalsColor stage..." );
			_rgbData = extractChannels(_canvas.normalSpecularMap, _copySubTextureChannelsRGB);
		}

		private function extractNormalsAlpha() : void
		{
			ConsoleView.instance.log( this, "extractNormalsAlpha stage..." );
			_alphaData = extractChannels(_canvas.normalSpecularMap, _copySubTextureChannelsA);
		}

		private function mergeNormalData() : void
		{
			ConsoleView.instance.log( this, "mergeNormalData stage..." );
			_paintingData.normalSpecularData = mergeRGBAData();
		}

		private function saveSourceData() : void
		{
			ConsoleView.instance.log( this, "saveSourceData stage..." );
			_paintingData.sourceBitmapData = saveLayerNoAlpha(_canvas.sourceTexture);
			ConsoleView.instance.log( this, "saveSourceData stage - source bmd bytes: " + _paintingData.sourceBitmapData.length );
		}

		private function onComplete() : void
		{
			_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_stage = null;
			_canvas = null;
			_context3D = null;
			_sourceRect = null;
			_destRect = null;
			_workerBitmapData.dispose();
			_workerBitmapData = null;

			dispatchEvent(new CanvasExportEvent(CanvasExportEvent.COMPLETE, _paintingData));
		}

		private function saveLayerNoAlpha(layer : Texture) : ByteArray
		{
			var context3D : Context3D = _canvas.stage3D.context3D;

			context3D.setRenderToBackBuffer();
			context3D.clear(0, 0, 0, 0);
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopySubTexture.copy(layer, _sourceRect, _destRect, context3D);
			_time = getTimer();
			context3D.drawToBitmapData(_workerBitmapData);
			ConsoleView.instance.log( this, "saveLayerNoAlpha - gpu read back - " + String( getTimer() - _time ) );
			var bytes:ByteArray = _workerBitmapData.getPixels(_workerBitmapData.rect);
			ConsoleView.instance.log( this, "saveLayerNoAlpha - bmd: " + _workerBitmapData.width + "x" + _workerBitmapData.rect.height );
			ConsoleView.instance.log( this, "saveLayerNoAlpha - bmd rect: " + _workerBitmapData.rect );
			ConsoleView.instance.log( this, "saveLayerNoAlpha - bmd bytes: " + bytes.length );
			return bytes;
		}

		private function mergeRGBAData() : ByteArray
		{
			ConsoleView.instance.log( this, "mergeRGBAData..." );

			_rgbData.position = 0;
			_alphaData.position = 0;
			var outputData : ByteArray = new ByteArray();

			var len : int = _canvas.width * _canvas.height;
//			ConsoleView.instance.log( this, "mergeRGBAData - len: " + len );
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
//			ConsoleView.instance.log( this, "mergeRGBAData - cleared" );
			_rgbData = null;
			_alphaData = null;
			return outputData;
		}

		private function extractChannels(layer : Texture, copier : CopySubTextureChannels) : ByteArray
		{
			_context3D.setRenderToBackBuffer();
			_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

			_context3D.clear(0, 0, 0, 1);
			copier.copy(layer, _sourceRect, _destRect, _context3D);
			_time = getTimer();
			_context3D.drawToBitmapData(_workerBitmapData);
			ConsoleView.instance.log( this, "extractChannels - gpu read back - " + String( getTimer() - _time ) );

			return _workerBitmapData.getPixels(_workerBitmapData.rect);
		}
	}
}
