package net.psykosoft.psykopaint2.home.model
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;

	import org.osflash.signals.Signal;

	public class ActiveGalleryPaintingModel
	{
		public var onUpdate : Signal = new Signal();

		private var _painting : GalleryImageProxy;

		public function ActiveGalleryPaintingModel()
		{
		}

		public function get painting() : GalleryImageProxy
		{
			return _painting;
		}

		public function set painting(value : GalleryImageProxy) : void
		{
			_painting = value;
			onUpdate.dispatch();
		}
	}
}
