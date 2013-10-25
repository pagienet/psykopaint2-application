package net.psykosoft.psykopaint2.core.io
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	import avm2.intrinsics.memory.li8;
	import avm2.intrinsics.memory.si8;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;

	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTextureChannels;
	import net.psykosoft.psykopaint2.paint.utils.CopyColorToBitmapDataUtil;

	public class CanvasDPPSerializer extends EventDispatcher
	{
		private static var _copySubTextureChannelsRGB : CopySubTextureChannels;
		private static var _copySubTextureChannelsA : CopySubTextureChannels;
		private static var _copyColorToBitmapData : CopyColorToBitmapDataUtil;

		private var _canvas : CanvasModel;
		private var _exportingStage : int;
		private var _context3D : Context3D;
		private var _sourceRect : Rectangle;
		private var _destRect : Rectangle;
		private var _stage : Stage;
		private var _ioAne : IOAneManager;

		private var _exportingStages : Array;

		private var _output : ByteArray;
		private var _colorDataOffset : uint;
		private var _normalSpecularOffset : uint;

		public function CanvasDPPSerializer(stage : Stage, ioAne : IOAneManager)
		{
			_stage = stage;
			_ioAne = ioAne;

			_copySubTextureChannelsRGB ||= new CopySubTextureChannels("xyz", "xyz");
			_copySubTextureChannelsA ||= new CopySubTextureChannels("w", "z");
			_copyColorToBitmapData ||= new CopyColorToBitmapDataUtil();
		}

		public function serialize(canvas : CanvasModel) : void
		{
			_exportingStages = [
				saveColorRGB,
				saveColorAlpha,
				mergeColorData,

				extractNormalsColor,
				extractNormalsAlpha,
				mergeNormalData,

				writeNormalSpecularOriginal
			];

			if (canvas.hasSourceImage())
				_exportingStages.push(saveSourceDataToByteArray);

			if (canvas.getColorBackgroundOriginal())
				_exportingStages.push(writeColorBackgroundOriginal);

			doExport(canvas);
		}

		private function doExport(canvas : CanvasModel) : void
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

			_output = new ByteArray();
			_output.length = calculateByteArrayLength();

			writeHeader();

			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function calculateByteArrayLength() : uint
		{
			// HEADER:
			// 2 UTF-string headers (2 bytes each)
			// 4 byte-string for DPP2
			// width, height (4 bytes each)
			// boolean (1 byte)
			// = 17
			var canvasBytes : int = _canvas.width * _canvas.height * 4;
			var size : int = 17 + PaintingFileUtils.PAINTING_FILE_VERSION.length;
			size += canvasBytes * 3;	// color data, normal data, normal specular original

			if (_canvas.hasSourceImage())
				size += canvasBytes;

			if (_canvas.getColorBackgroundOriginal())
				size += canvasBytes;

			return size;
		}

		private function writeHeader() : void
		{
			_output.writeUTF("DPP2");
			_output.writeUTF(PaintingFileUtils.PAINTING_FILE_VERSION);

			// Write dimensions.
			_output.writeInt(_canvas.width);
			_output.writeInt(_canvas.height);

			// write isPhotoPainting flag
			_output.writeBoolean(_canvas.hasSourceImage());

		}

		private function onEnterFrame(event : Event) : void
		{
			if (++_exportingStage < _exportingStages.length)
				executeStage();
			else
				onComplete();
		}

		private function executeStage() : void
		{
			_exportingStages[_exportingStage]();
			dispatchEvent(new CanvasSerializationEvent(CanvasSerializationEvent.PROGRESS, _output, _exportingStage, _exportingStages.length));
		}

		// the stages:
		private function saveColorRGB() : void
		{
			_colorDataOffset = _output.position;
			extractChannels(_canvas.colorTexture, _copySubTextureChannelsRGB);
		}

		private function saveColorAlpha() : void
		{
			extractChannels(_canvas.colorTexture, _copySubTextureChannelsA);
		}

		private function mergeColorData() : void
		{
			mergeRGBAData(_colorDataOffset);
			_output.position = _colorDataOffset + _canvas.width * _canvas.height * 4;
		}

		private function extractNormalsColor() : void
		{
			_normalSpecularOffset = _output.position;
			extractChannels(_canvas.normalSpecularMap, _copySubTextureChannelsRGB);
		}

		private function extractNormalsAlpha() : void
		{
			extractChannels(_canvas.normalSpecularMap, _copySubTextureChannelsA);
		}

		private function mergeNormalData() : void
		{
			mergeRGBAData(_normalSpecularOffset);
			_output.position = _normalSpecularOffset + _canvas.width * _canvas.height * 4;
		}

		private function writeNormalSpecularOriginal() : void
		{
			_output.writeBytes(_canvas.getNormalSpecularOriginal(), 0, _canvas.width*_canvas.height*4);
		}

		private function saveSourceDataToByteArray() : void
		{
			saveLayerNoAlpha(_canvas.sourceTexture);
		}

		private function writeColorBackgroundOriginal() : void
		{
			_output.writeBytes(_canvas.getColorBackgroundOriginal(), 0, _canvas.width*_canvas.height*4);
		}

		private function onComplete() : void
		{
			_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_stage = null;
			_canvas = null;
			_context3D = null;
			_sourceRect = null;
			_destRect = null;
			_ioAne = null;

			dispatchEvent(new CanvasSerializationEvent(CanvasSerializationEvent.COMPLETE, _output));
		}

		private function saveLayerNoAlpha(layer : Texture) : void
		{
			var context3D : Context3D = _canvas.stage3D.context3D;
			var bitmapData : BitmapData = new TrackedBitmapData(_canvas.width, _canvas.height, false);
			context3D.setRenderToBackBuffer();
			context3D.clear(0, 0, 0, 0);
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopySubTexture.copy(layer, _sourceRect, _destRect, context3D);
			context3D.drawToBitmapData(bitmapData);
			bitmapData.copyPixelsToByteArray(bitmapData.rect, _output);
			bitmapData.dispose();
		}

		private function mergeRGBAData(offset : uint) : void
		{
			var len : int = _canvas.width * _canvas.height * 4;

			if (CoreSettings.RUNNING_ON_iPAD)
				_ioAne.extension.mergeRgbaPerByte(_output, offset, len); // Takes about 30ms
			else
				mergeRGBADataAS3Pure(len, offset);
		}

		private function mergeRGBADataAS3Pure(len : int, offset : int) : void
		{
			var rOffset : int = 1;
			var gOffset : int = 2;
			var bOffset : int = 3;
			var aOffset : int = len + 3;

			ApplicationDomain.currentDomain.domainMemory = _output;

			len += offset;

			for (var i : int = offset; i < len; i += 4) {
				var r : uint = li8(int(i + rOffset));
				var g : uint = li8(int(i + gOffset));
				var b : uint = li8(int(i + bOffset));
				var a : uint = li8(int(i + aOffset));

				si8(b, i);
				si8(g, int(i + 1));
				si8(r, int(i + 2));
				si8(a, int(i + 3));
			}

			ApplicationDomain.currentDomain.domainMemory = null;
		}

		private function extractChannels(layer : Texture, copier : CopySubTextureChannels) : void
		{
			_context3D.setRenderToBackBuffer();
			_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

			_context3D.clear(0, 0, 0, 1);
			copier.copy(layer, _sourceRect, _destRect, _context3D);
			var bitmapData : BitmapData = new TrackedBitmapData(_canvas.width, _canvas.height, false);
			_context3D.drawToBitmapData(bitmapData);
			bitmapData.copyPixelsToByteArray(bitmapData.rect, _output);
			bitmapData.dispose();
		}
	}
}
