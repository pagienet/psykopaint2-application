package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyLovePaintingFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyLovePaintingSucceededSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLovePaintingSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseGallerySignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomePanningToggleSignal;

	public class GalleryShareSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view : GalleryShareSubNavView;

		[Inject]
		public var activeGalleryPaintingModel : ActiveGalleryPaintingModel;

		[Inject]
		public var loggedInUser : LoggedInUserProxy;

		public function GalleryShareSubNavViewMediator()
		{
			super();
		}

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
					goBack();
					break;
			}
		}

		private function sharePainting() : void
		{
			requestNavigationStateChange(NavigationStateType.GALLERY_SHARE);
		}

		private function goBack() : void
		{
			requestNavigationStateChange(NavigationStateType.GALLERY_PAINTING);
		}
	}
}
