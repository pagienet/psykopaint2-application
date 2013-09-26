package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseGallerySignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestExitGallerySignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomePanningToggleSignal;

	public class GalleryBrowseSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:GalleryBrowseSubNavView;

		[Inject]
		public var requestBrowseGallerySignal : RequestBrowseGallerySignal;

		[Inject]
		public var requestHomePanningToggleSignal:RequestHomePanningToggleSignal;

		[Inject]
		public var requestExitGallerySignal : RequestExitGallerySignal;

		private var _galleryTypeMap : Array;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			_galleryTypeMap = [];
			_galleryTypeMap[GalleryBrowseSubNavView.ID_FOLLOWING] = GalleryType.FOLLOWING;
			_galleryTypeMap[GalleryBrowseSubNavView.ID_MOST_LOVED] = GalleryType.MOST_LOVED;
			_galleryTypeMap[GalleryBrowseSubNavView.ID_MOST_RECENT] = GalleryType.MOST_RECENT;
			_galleryTypeMap[GalleryBrowseSubNavView.ID_YOURS] = GalleryType.YOURS;
		}

		override protected function onViewDisabled() : void
		{
			requestHomePanningToggleSignal.dispatch(1);
			super.onViewDisabled();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case GalleryBrowseSubNavView.ID_BACK:
					requestExitGallerySignal.dispatch();
//					requestHomePanningToggleSignal.dispatch(true);
					break;
				default:
					requestBrowseGallerySignal.dispatch(_galleryTypeMap[id]);
			}
		}
	}
}
