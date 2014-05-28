package net.psykosoft.psykopaint2.core.io
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.textures.RectangleTexture;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.net.ObjectEncoding;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	
	import avm2.intrinsics.memory.li8;
	import avm2.intrinsics.memory.si8;
	
	import net.psykosoft.psykopaint2.base.utils.images.ImageDataUtils;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PPPFileData;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTextureChannels;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	public class CanvasPPPSerializer  extends EventDispatcher
	{
		private static var _copySubTextureChannelsRGB : CopySubTextureChannels;
		private static var _copySubTextureChannelsA : CopySubTextureChannels;
		
		private var _canvas : CanvasModel;
		private var _context3D : Context3D;
		private var _sourceRect : Rectangle;
		private var _destRect : Rectangle;
		private var _stage : Stage;
		private var _ioAne : IOAneManager;
		private var _paintSettings:UserPaintSettingsModel;
		
		private var _PPPFileData:PPPFileData;
		
		public function CanvasPPPSerializer(stage : Stage, ioAne : IOAneManager)
		{
			_stage = stage;
			_ioAne = ioAne;
			
			_copySubTextureChannelsRGB ||= new CopySubTextureChannels("xyz", "xyz");
			_copySubTextureChannelsA ||= new CopySubTextureChannels("w", "z");
		}
		
		public function serialize(canvas : CanvasModel, paintSettings : UserPaintSettingsModel) : void
		{
			
			if (_canvas) throw "Export already in progress!";
			_canvas = canvas;
			_paintSettings = paintSettings;
			
			init();
			
		}
		

		private function init() : void
		{
			_context3D = _canvas.stage3D.context3D;
			
			// TODO: sourceRect & destRect are no longer necessary, we can just copy textures
			_sourceRect = new Rectangle(0, 0, 1, 1);
			_destRect = new Rectangle(0, 0, 1, 1);
			
			_PPPFileData = new PPPFileData();
			_PPPFileData.version = PaintingFileUtils.PAINTING_FILE_VERSION;
			
			// Write dimensions.
			_PPPFileData.width = _canvas.width;
			_PPPFileData.height = _canvas.height;
			
			// write isPhotoPainting flag
			_PPPFileData.isPhotoPainting = _paintSettings.hasSourceImage;
			
			// MATHIEU: MIGHT WANT TO SEE IF WE REALLY NEED THAT IN THE FUTURE
			//_paintingVO.hasColorBackgroundOriginal = (_canvas.getColorBackgroundOriginal() != null);  
			
			//COLOR PALETTES
			var palettes:Array = [];
			for (var i:int = 0; i <_paintSettings.colorPalettes.length; i++) 
			{
				palettes[i] = [];
				for (var j:int = 0; j < _paintSettings.colorPalettes[i].length; j++) 
				{
					palettes[i][j] = _paintSettings.colorPalettes[i][j];
				}
			}
				
			
			_PPPFileData.colorPalettes = palettes;
			
			//SAVE COLOR MAP
			var colorBytes:ByteArray = new ByteArray();
			extractChannels(_canvas.colorTexture, _copySubTextureChannelsRGB, colorBytes);
			//MATHIEU: NEED TO ADD THE ALPHA CHANNEL AND MERGE IT
			extractChannels(_canvas.colorTexture, _copySubTextureChannelsA, colorBytes);
			//extractChannels(_canvas.colorTexture, _copySubTextureChannelsA);
			mergeRGBAData(0,colorBytes);
			_PPPFileData.colorData = colorBytes;
			
			//NORMAL/SPECULAR MAP (ALPHA CHANNEL)
			_PPPFileData.normalSpecularData = copyNormalSpecular();
			
			
			
			//var original : BitmapData = _canvas.getNormalSpecularOriginal();
			//var bytes:ByteArray = new ByteArray();
			//original.copyPixelsToByteArray(original.rect, bytes);
			_PPPFileData.surfaceNormalSpecularData = _canvas.getNormalSpecularOriginal();
				
			//	.setPixels(paintingDataVO.surfaceNormalSpecularData.rect, surfaceNormalSpecularDataBytes);
			
			if (_paintSettings.hasSourceImage)
			{
				_PPPFileData.sourceImageData = saveLayerNoAlpha(_canvas.sourceTexture);
			}
			if ((_canvas.getColorBackgroundOriginal() != null))
			{
				_PPPFileData.colorBackgroundOriginal = _canvas.getColorBackgroundOriginal();
			}
			
			
			_stage = null;
			_canvas = null;
			_context3D = null;
			_sourceRect = null;
			_destRect = null;
			_ioAne = null;
			_paintSettings = null;
			
			
			
			var filebytes : ByteArray = new ByteArray();
			filebytes.objectEncoding = ObjectEncoding.AMF3;
			filebytes.writeObject(_PPPFileData);
			//filebytes.compress(CompressionAlgorithm.DEFLATE);
			
			
			
			dispatchEvent(new CanvasSerializationEvent(CanvasSerializationEvent.COMPLETE, filebytes));
			
		}
		
		private function calculateByteArrayLength() : uint
		{
			// HEADER:
			// 2 UTF-string headers (2 bytes each)
			// 4 byte-string for DPP2
			// width, height (4 bytes each)
			// boolean (1 byte)
			// boolean (1 byte)
			// = 18
			var canvasBytes : int = _canvas.width * _canvas.height * 4;
			var size : int = 18 + PaintingFileUtils.PAINTING_FILE_VERSION.length;
			size += canvasBytes * 3;	// color data, normal data, normal specular original
			
			if (_paintSettings.hasSourceImage)
				size += canvasBytes;
			
			if (_canvas.getColorBackgroundOriginal() != null)
				size += canvasBytes;
			
			//TODO: calculate length of color palettes here
			
			return size;
		}
		
	
	
		
		/*
		private function mergeColorData() : void
		{
			mergeRGBAData(_colorDataOffset);
			_output.position = _colorDataOffset + _canvas.width * _canvas.height * 4;
		}*/
		
		private function copyNormalSpecular() : ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			
			_context3D.setRenderToBackBuffer();
			_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			_context3D.clear(0, 0, 0, 1);
			CopyTexture.copy(_canvas.normalSpecularMap, _context3D);
			var bitmapData : BitmapData = new TrackedBitmapData(_canvas.width, _canvas.height, false);
			_context3D.drawToBitmapData(bitmapData);
			bitmapData.copyPixelsToByteArray(bitmapData.rect, bytes);
			bitmapData.dispose();
			var len : int =  _canvas.width * _canvas.height * 4;
			ImageDataUtils.ARGBtoBGRA(bytes, len, 0);
			return bytes
		}
	
		
		
		private function saveLayerNoAlpha(layer : RectangleTexture) : ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			var context3D : Context3D = _canvas.stage3D.context3D;
			var bitmapData : BitmapData = new TrackedBitmapData(_canvas.width, _canvas.height, false);
			context3D.setRenderToBackBuffer();
			context3D.clear(0, 0, 0, 0);
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopySubTexture.copy(layer, _sourceRect, _destRect, context3D);
			context3D.drawToBitmapData(bitmapData);
			bitmapData.copyPixelsToByteArray(bitmapData.rect, bytes);
			bitmapData.dispose();
			return bytes;
		}
		
		
		private function mergeRGBAData(offset : uint,bytes:ByteArray) : void
		{
			var len : int = _canvas.width * _canvas.height * 4;
			
			if (CoreSettings.RUNNING_ON_iPAD)
				_ioAne.extension.mergeRgbaPerByte(bytes, offset, len); // Takes about 30ms
			else
				mergeRGBADataAS3Pure(len, offset,bytes);
		}
		
		private function mergeRGBADataAS3Pure(len : int, offset : int,bytes:ByteArray) : void
		{
			var rOffset : int = 1;
			var gOffset : int = 2;
			var bOffset : int = 3;
			var aOffset : int = len + 3;
			
			var tmp:ByteArray = ApplicationDomain.currentDomain.domainMemory;
			ApplicationDomain.currentDomain.domainMemory = bytes;
			
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
			
			ApplicationDomain.currentDomain.domainMemory = tmp;
		}
		
		private function extractChannels(layer : RectangleTexture, copier : CopySubTextureChannels, target:ByteArray ) : void
		{
		//	var bytes:ByteArray = new ByteArray();
			_context3D.setRenderToBackBuffer();
			_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			
			//MATHIEU: ORIGNAL: I THINK LAST ONE CLEAR THE ALPHA _context3D.clear(0, 0, 0, 1);
			//SETTING IT TO 0
			_context3D.clear(0, 0, 0, 0);
			copier.copy(layer, _sourceRect, _destRect, _context3D);
			var bitmapData : BitmapData = new TrackedBitmapData(_canvas.width, _canvas.height, false);
			_context3D.drawToBitmapData(bitmapData);
			bitmapData.copyPixelsToByteArray(bitmapData.rect, target);
			bitmapData.dispose();
			//return bytes;
		}
		
		
	}
}