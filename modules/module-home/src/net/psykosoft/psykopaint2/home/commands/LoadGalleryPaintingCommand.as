package net.psykosoft.psykopaint2.home.commands
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryPaintingIOErrorSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryPaintingLoadedSignal;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;

	public class LoadGalleryPaintingCommand
	{
		[Inject]
		public var notifyGalleryPaintingLoadedSignal : NotifyGalleryPaintingLoadedSignal;

		[Inject]
		public var notifyGalleryPaintingIOErrorSignal : NotifyGalleryPaintingIOErrorSignal;

		[Inject]
		public var galleryImage : GalleryImageProxy;

		[Inject]
		public var activeGalleryPaintingModel : ActiveGalleryPaintingModel;

		public function execute() : void
		{
			activeGalleryPaintingModel.activePainting = galleryImage;
			galleryImage.loadFullsized(onComplete, onError);
		}

		private function onComplete(bitmapData : BitmapData) : void
		{
			notifyGalleryPaintingLoadedSignal.dispatch(galleryImage, bitmapData);
		}

		private function onError() : void
		{
			notifyGalleryPaintingIOErrorSignal.dispatch();
		}
	}
}
