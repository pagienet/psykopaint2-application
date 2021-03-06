package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
import net.psykosoft.psykopaint2.core.models.NavigationStateModel;
import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

	public class GalleryBrowseSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:GalleryBrowseSubNavView;

		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;

		[Inject]
		public var loggedInUser : LoggedInUserProxy;

		[Inject]
		public var stateModel:NavigationStateModel;

		private var _navigationStateTypeMap : Array;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			_navigationStateTypeMap = [];
			_navigationStateTypeMap[GalleryBrowseSubNavView.ID_FOLLOWING] = NavigationStateType.GALLERY_BROWSE_FOLLOWING;
			_navigationStateTypeMap[GalleryBrowseSubNavView.ID_MOST_LOVED] = NavigationStateType.GALLERY_BROWSE_MOST_LOVED;
			_navigationStateTypeMap[GalleryBrowseSubNavView.ID_MOST_RECENT] = NavigationStateType.GALLERY_BROWSE_MOST_RECENT;
			_navigationStateTypeMap[GalleryBrowseSubNavView.ID_YOURS] = NavigationStateType.GALLERY_BROWSE_YOURS;

			// Start with the correct button selected.
			switch(stateModel.currentState) {
				case NavigationStateType.GALLERY_BROWSE_FOLLOWING:
					view.startWithSelectedId = GalleryBrowseSubNavView.ID_FOLLOWING;
					break;
				case NavigationStateType.GALLERY_BROWSE_MOST_LOVED:
					view.startWithSelectedId = GalleryBrowseSubNavView.ID_MOST_LOVED;
					break;
				case NavigationStateType.GALLERY_BROWSE_MOST_RECENT:
					view.startWithSelectedId = GalleryBrowseSubNavView.ID_MOST_RECENT;
					break;
				case NavigationStateType.GALLERY_BROWSE_YOURS:
					view.startWithSelectedId = GalleryBrowseSubNavView.ID_YOURS;
					break;
			}
		}

		override protected function onButtonClicked( id:String ):void {
			/*switch( id ) {
				case GalleryBrowseSubNavView.ID_BACK:
					requestNavigationStateChange(NavigationStateType.HOME_ON_EASEL);
//					requestHomePanningToggleSignal.dispatch(true);
					break;
				default:*/
//			}

			if ((id == GalleryBrowseSubNavView.ID_YOURS || id ==  NavigationStateType.GALLERY_BROWSE_FOLLOWING) && !loggedInUser.isLoggedIn())
				requestShowPopUpSignal.dispatch(PopUpType.LOGIN);
			else
				requestNavigationStateChange(_navigationStateTypeMap[id]);

		}
	}
}
