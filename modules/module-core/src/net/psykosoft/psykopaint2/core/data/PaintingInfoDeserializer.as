package net.psykosoft.psykopaint2.core.data
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.ObjectEncoding;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;

	public class PaintingInfoDeserializer extends EventDispatcher
	{
		private var _paintingInfoVO : PaintingInfoVO;
		private var _fileBytes : TrackedByteArray;

		public function PaintingInfoDeserializer()
		{
		}

		public function get paintingInfoVO() : PaintingInfoVO
		{
			return _paintingInfoVO;
		}

		public function deserialize(bytes : TrackedByteArray) : void
		{
			_paintingInfoVO = new PaintingInfoVO();
			_fileBytes = bytes;
			
			var ippFileData :PPPIFileData = new PPPIFileData();
			
			//fileBytes.uncompress(CompressionAlgorithm.DEFLATE);
			_fileBytes.objectEncoding = ObjectEncoding.AMF3;
			registerClassAlias("net.psykosoft.psykopaint2.core.data.IPPFileData", PPPIFileData);
			ippFileData = PPPIFileData(_fileBytes.readObject()) ;
			
			//CONVERT IPP FILE TO PAINTING INFO VO
			_paintingInfoVO.fileVersion = ippFileData.version;
			_paintingInfoVO.id = ippFileData.id;
			_paintingInfoVO.width = ippFileData.width;
			_paintingInfoVO.height = ippFileData.height;
			_paintingInfoVO.lastSavedOnDateMs = ippFileData.dateTimestamp;
			var thumbnailBytesLength : uint = _paintingInfoVO.width * _paintingInfoVO.height*4;
			
			
			var bmd:BitmapData = new BitmapData(ippFileData.width, ippFileData.height, true, 0); // 32 bit transparent bitmap
			bmd.setPixels(bmd.rect, ippFileData.thumbnailBmd);
			_paintingInfoVO.thumbnailBmd = bmd;
			
			//CoreSettings.STAGE.addChild(new Bitmap(ippFileData.thumbnailBmd));
			
			//_paintingInfoVO.thumbnailBmd = new BitmapData(200,200,false,0xFF00FF);
			
			// Read low res surfaces.
			_paintingInfoVO.colorPreviewData = ippFileData.colorPreviewData;
			_paintingInfoVO.normalSpecularPreviewData = ippFileData.normalSpecularPreviewData;
			
			
			
			
			
			
			/*
			bytes.position = 0;
			// Check version first.
			if (bytes.readUTF() != "IPP2")
				throw "Incorrect file type";

			_paintingInfoVO.fileVersion = bytes.readUTF();
			if (_paintingInfoVO.fileVersion != PaintingFileUtils.PAINTING_FILE_VERSION)
				throw "Incorrect file version";

			// Read and set exposed single value data.
			_paintingInfoVO.id = bytes.readUTF();
			_paintingInfoVO.width = bytes.readInt();
			_paintingInfoVO.height = bytes.readInt();
			_paintingInfoVO.lastSavedOnDateMs = bytes.readFloat();
			*/
			//PaintingFileUtils.decodePNG(_paintingInfoVO.thumbnail, thumbnailBytesLength, onDecodePNGComplete);
			
			_fileBytes.clear();
			_fileBytes = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		/*
		private function onDecodePNGComplete(thumbBmd : BitmapData) : void
		{

			// Set thumb.
			_paintingInfoVO.thumbnail = thumbBmd;

			// Read low res surfaces.
			_paintingInfoVO.colorPreviewData = PaintingFileUtils.decodeImage(_fileBytes, _paintingInfoVO.width, _paintingInfoVO.height);
			_paintingInfoVO.normalSpecularPreviewData = PaintingFileUtils.decodeImage(_fileBytes, _paintingInfoVO.width, _paintingInfoVO.height);
			_fileBytes.clear();
			_fileBytes = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}*/
	}
}
