package net.psykosoft.psykopaint2.core.services
{
	import net.psykosoft.psykopaint2.base.utils.io.XMLLoader;
	import net.psykosoft.psykopaint2.core.models.FileSourceImageProxy;
	import net.psykosoft.psykopaint2.core.models.ImageCollectionSource;
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;

	public class XMLSampleImageService implements SampleImageService
	{
		private var _xml : XML;
		private var _indexToFetch : int;
		private var _amountToFetch : int;
		private var _callback : Function;

		public function XMLSampleImageService()
		{
		}

		public function fetchImages(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			if (!_xml) {
				_indexToFetch = index;
				_amountToFetch = amount;
				_callback = onSuccess;
				loadXML();
			}
			else
				parseXML(index, amount, onSuccess);
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
			parseXML(_indexToFetch, _amountToFetch, _callback);
		}

		private function parseXML(index : uint, amount : uint, onSuccess : Function) : void
		{
			var lowResPath : String = _xml.path.lowRes;
			var highResPath : String = _xml.path.highRes;
			var originalFilename : String = _xml.path.originals;
			var images : XMLList = _xml.images.image;
			var collection : SourceImageCollection = new SourceImageCollection();
			var max : int = index + amount;

			collection.source = ImageCollectionSource.SAMPLE_IMAGES;
			collection.index = index;
			collection.numTotalImages = images.length();

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

			onSuccess(collection);
		}
	}
}
