package net.psykosoft.psykopaint2.home.views.home
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.home.signals.RequestSetGalleryPaintingSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class GalleryViewMediator extends Mediator
	{
		[Inject]
		public var view : GalleryView;

		[Inject]
		public var requestSetGalleryPaintingSignal : RequestSetGalleryPaintingSignal;


		public function GalleryViewMediator()
		{
		}

		override public function initialize() : void
		{
			super.initialize();
			requestSetGalleryPaintingSignal.add(onRequestSetGalleryPainting);
		}

		override public function destroy() : void
		{
			super.destroy();
			requestSetGalleryPaintingSignal.remove(onRequestSetGalleryPainting);
		}

		private function onRequestSetGalleryPainting(galleryImageProxy : GalleryImageProxy) : void
		{
			// TODO: Pass stuff on to view, which loads stuff through proxy
		}
	}
}
