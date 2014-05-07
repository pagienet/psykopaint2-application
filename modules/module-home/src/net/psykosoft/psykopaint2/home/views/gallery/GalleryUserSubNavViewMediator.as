package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;

	public class GalleryUserSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view : GalleryUserSubNavView;

		[Inject]
		public var loggedInUser : LoggedInUserProxy;

		[Inject]
		public var activePaintingModel : ActiveGalleryPaintingModel;

		private var _isFollowing : Boolean;
		private var _userID : int = -1;
		private var _lastVisitedGalleryType:uint;
		private var _galleryTypeNavStateMap:Vector.<String> = new <String>[null, NavigationStateType.GALLERY_BROWSE_FOLLOWING, NavigationStateType.GALLERY_BROWSE_YOURS, NavigationStateType.GALLERY_BROWSE_MOST_RECENT, NavigationStateType.GALLERY_BROWSE_MOST_LOVED, null];

		public function GalleryUserSubNavViewMediator()
		{
			super();
		}

		override public function initialize() : void
		{
			// Init.
			registerView(view);
			super.initialize();

			_userID = -1;

			activePaintingModel.onUpdate.add(updateUI);
			updateUI();
		}


		override public function destroy() : void
		{
			super.destroy();

			activePaintingModel.onUpdate.remove(updateUI);
		}

		private function updateUI() : void
		{
			var activePainting : GalleryImageProxy = activePaintingModel.painting;

			view.enableButtonWithId(GalleryUserSubNavView.ID_FOLLOW, false);

			if (_userID != activePainting.userID) {
				_userID = activePainting.userID;
				loggedInUser.getIsFollowingUser(_userID, onGetIsFollowingUserResult, onGetIsFollowingUserError);
			}

			if (activePainting.collectionType != GalleryType.NONE && activePainting.collectionType != GalleryType.USER) {
				_lastVisitedGalleryType = activePainting.collectionType;
			}
		}

		private function onGetIsFollowingUserResult(isFollowing : Boolean) : void
		{
			if (view.isEnabled)
				setFollowing(isFollowing);
		}

		private function setFollowing(value : Boolean) : void
		{
			var label : String;
			var icon : String;

			_isFollowing = value;

			if (_isFollowing) {
				label = "UNFOLLOW";
				icon = ButtonIconType.UNFOLLOW;
			}
			else {
				label = "FOLLOW";
				icon = ButtonIconType.FOLLOW;
			}

			view.relabelButtonWithId(GalleryUserSubNavView.ID_FOLLOW, label, icon);
			view.enableButtonWithId(GalleryUserSubNavView.ID_FOLLOW, true);
		}

		private function onGetIsFollowingUserError(errorCode : uint, reason : String) : void
		{
			trace ("WARNING: Error requesting isFollowingUser: " + errorCode);
		}

		override protected function onButtonClicked(id : String) : void
		{
			switch (id) {
				case GalleryUserSubNavView.ID_FOLLOW:
					toggleFollowing();
					break;
				case GalleryUserSubNavView.ID_BACK:
					requestNavigationStateChange(_galleryTypeNavStateMap[_lastVisitedGalleryType]);
					break;
			}
		}

		private function toggleFollowing() : void
		{
			if (_isFollowing)
				loggedInUser.unfollowUser(activePaintingModel.painting.userID, onToggleFollowSuccess, onToggleFollowingFailed);
			else
				loggedInUser.followUser(activePaintingModel.painting.userID, onToggleFollowSuccess, onToggleFollowingFailed);
		}

		private function onToggleFollowSuccess() : void
		{
			setFollowing(!_isFollowing);
		}

		private function onToggleFollowingFailed(errorCode : uint, reason : String) : void
		{
			setFollowing(_isFollowing);
		}
	}
}
