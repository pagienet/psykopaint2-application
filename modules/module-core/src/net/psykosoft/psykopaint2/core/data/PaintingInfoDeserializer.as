package net.psykosoft.psykopaint2.core.data
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	public class PaintingInfoDeserializer extends EventDispatcher
	{
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
			trace (thumbnailBytesLength);
			PaintingFileUtils.decodePNG(bytes, thumbnailBytesLength, onDecodePNGComplete);
		}

		private function onDecodePNGComplete(thumbBmd : BitmapData) : void
		{

			// Set thumb.
			_vo.thumbnail = thumbBmd;

			// Read low res surfaces.
			_vo.colorPreviewData = PaintingFileUtils.decodeImage(_bytes, _vo.width, _vo.height);
			_vo.normalSpecularPreviewData = PaintingFileUtils.decodeImage(_bytes, _vo.width, _vo.height);

			_bytes.clear();

			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
