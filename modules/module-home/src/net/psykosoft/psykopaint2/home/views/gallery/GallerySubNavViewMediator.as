package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseGallerySignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestExitGallerySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomePanningToggleSignal;

	public class GallerySubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:GallerySubNavView;

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
			_galleryTypeMap[GallerySubNavView.ID_FOLLOWING] = GalleryType.FOLLOWING;
			_galleryTypeMap[GallerySubNavView.ID_MOST_LOVED] = GalleryType.MOST_LOVED;
			_galleryTypeMap[GallerySubNavView.ID_MOST_RECENT] = GalleryType.MOST_RECENT;
			_galleryTypeMap[GallerySubNavView.ID_YOURS] = GalleryType.YOURS;
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case GallerySubNavView.ID_BACK:
					requestExitGallerySignal.dispatch();
					requestHomePanningToggleSignal.dispatch( true );
					break;
				default :
					requestBrowseGallerySignal.dispatch(_galleryTypeMap[id]);
			}
		}
	}
}
