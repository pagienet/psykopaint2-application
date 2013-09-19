package net.psykosoft.psykopaint2.book.services
{
	import net.psykosoft.psykopaint2.base.utils.io.XMLLoader;
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.model.FileSourceImageProxy;
	import net.psykosoft.psykopaint2.book.model.SourceImageCollection;
	import net.psykosoft.psykopaint2.book.model.SourceImageProxy;
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImagesFetchedSignal;

	public class DummyCameraRollService implements CameraRollService
	{
		[Inject]
		public var notifySourceImagesFetchedSignal : NotifySourceImagesFetchedSignal;

		private var _xml : XML;
		private var _indexToFetch : int;
		private var _amountToFetch : int;
		private var _index : int;

		public function DummyCameraRollService()
		{
		}

		public function fetchImages(index : int, amount : int) : void
		{
			_index = index;
			if (!_xml) {
				_indexToFetch = index;
				_amountToFetch = amount;
				loadXML();
			}
			else
				parseXML(index, amount);
		}

		private function loadXML() : void
		{
			var date:Date = new Date();
			var cacheAnnihilator:String = "?t=" + String( date.getTime() ) + Math.round( 1000 * Math.random() );
			var xmlLoader : XMLLoader = new XMLLoader();
			xmlLoader.loadAsset("/book-packaged/samples/samples_thumbs.xml" + cacheAnnihilator, onXMLLoaded);
		}

		private function onXMLLoaded(xml : XML) : void
		{
			_xml = xml;
			parseXML(_indexToFetch, _amountToFetch);
		}

		private function parseXML(index : uint, amount : uint) : void
		{
			var lowResPath : String = _xml.path;
			var highResPath : String = _xml.highRes;
			var originalFilename : String = _xml.originals;
			var images : XMLList = _xml.images.image;
			var collection : SourceImageCollection = new SourceImageCollection();
			var max : int = index + amount;

			collection.source = BookImageSource.CAMERA_IMAGES;
			collection.index = _index;

			if (amount == 0 || max > images.length())
				max = images.length();

			for (var i : uint = index; i < max; ++i) {
				var baseFilename : String = images[i].@name;
				var imageVO : FileSourceImageProxy = new FileSourceImageProxy();
				imageVO.id = i;
				imageVO.highResThumbnailFilename = highResPath + baseFilename;
				imageVO.lowResThumbnailFilename = lowResPath + baseFilename;
				imageVO.originalFilename = originalFilename + baseFilename;
				collection.images.push(imageVO);
			}

			notifySourceImagesFetchedSignal.dispatch(collection);
		}
	}
}
