package net.psykosoft.psykopaint2.home.model
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;

	import org.osflash.signals.Signal;

	// sadly, only so the view can access it, since it's initialized too late
	public class ActiveGalleryPaintingModel
	{
		private var _activePainting : GalleryImageProxy;
		public var onChange : Signal;

		public function ActiveGalleryPaintingModel()
		{
			onChange = new Signal();
		}

		public function get activePainting() : GalleryImageProxy
		{
			return _activePainting;
		}

		public function set activePainting(value : GalleryImageProxy) : void
		{
			if (value == _activePainting) return;
			_activePainting = value;
			onChange.dispatch();
		}
	}
}
