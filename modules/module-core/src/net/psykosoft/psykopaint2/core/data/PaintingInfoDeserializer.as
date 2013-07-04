package net.psykosoft.psykopaint2.core.data
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	public class PaintingInfoDeserializer extends EventDispatcher
	{
		// TODO: Move to PaintingInfo conversion tool
		public static const SURFACE_PREVIEW_SHRINK_FACTOR : Number = 4; // powers of 2, integers > 1

		private var _vo : PaintingInfoVO;
		private var _bytes : ByteArray;

		public function PaintingInfoDeserializer()
		{
		}

		public function get paintingInfoVO() : PaintingInfoVO
		{
			return _vo;
		}

		public function deserialize(bytes : ByteArray) : void
		{
			_vo = new PaintingInfoVO();
			_bytes = bytes;

			PaintingFileUtils.uncompressData(bytes);

			bytes.position = 0;
			// Check version first.
			_vo.fileVersion = bytes.readUTF();
			if (_vo.fileVersion != PaintingFileUtils.PAINTING_FILE_VERSION) {
				trace("PaintingVO deSerialize() - ***WARNING*** Unable to interpret loaded painting file, version is [" + _vo.fileVersion + "] and app is using version [" + PaintingFileUtils.PAINTING_FILE_VERSION + "]");
				return;
			}

			// Read and set exposed single value data.
			_vo.id = bytes.readUTF();
			_vo.width = bytes.readInt();
			_vo.height = bytes.readInt();
			_vo.lastSavedOnDateMs = bytes.readFloat();
			var thumbnailBytesLength : uint = bytes.readUnsignedInt();

			// Read and decode thumb.
			PaintingFileUtils.decodePNG(bytes, thumbnailBytesLength, onDecodePNGComplete);
		}

		private function onDecodePNGComplete(thumbBmd : BitmapData) : void
		{

			// Set thumb.
			_vo.thumbnail = thumbBmd;

			// Read low res surfaces.
			_vo.colorSurfacePreview = PaintingFileUtils.decodeImage(_bytes, _vo.width, _vo.height);
			_vo.normalsSurfacePreview = PaintingFileUtils.decodeImage(_bytes, _vo.width, _vo.height);

			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
