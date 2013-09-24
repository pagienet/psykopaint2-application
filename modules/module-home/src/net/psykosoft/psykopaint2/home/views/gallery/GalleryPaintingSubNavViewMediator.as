package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseGallerySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomePanningToggleSignal;

	public class GalleryPaintingSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view : GalleryPaintingSubNavView;

		[Inject]
		public var requestHomePanningToggleSignal:RequestHomePanningToggleSignal;

		[Inject]
		public var requestBrowseGallery : RequestBrowseGallerySignal;

		override public function initialize() : void
		{
			// Init.
			registerView(view);
			super.initialize();
		}

		override protected function onButtonClicked(id : String) : void
		{
			switch (id) {
				case GalleryBrowseSubNavView.ID_BACK:
					requestHomePanningToggleSignal.dispatch(false);
					// TODO:Should go back to previously active book state
					requestBrowseGallery.dispatch(GalleryType.MOST_RECENT);
					break;
			}
		}
	}
}
