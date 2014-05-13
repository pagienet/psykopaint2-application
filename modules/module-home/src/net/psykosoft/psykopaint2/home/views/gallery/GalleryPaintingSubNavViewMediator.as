package net.psykosoft.psykopaint2.home.views.gallery
{

import com.milkmangames.nativeextensions.GoViral;

import flash.display.Bitmap;

import flash.display.BitmapData;

import net.psykosoft.psykopaint2.base.utils.alert.Alert;
import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;
import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.services.GalleryService;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;

	public class GalleryPaintingSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view : GalleryPaintingSubNavView;

		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;

		[Inject]
		public var activePaintingModel : ActiveGalleryPaintingModel;

		[Inject]
		public var galleryService : GalleryService;

		[Inject]
		public var loggedInUser : LoggedInUserProxy;

		[Inject]
		public var socialSharingManager:SocialSharingManager;


		public function GalleryPaintingSubNavViewMediator()
		{
			super();
		}

		override public function initialize() : void
		{
			view.setupSignal.addOnce(onViewSetUp);
			loggedInUser.onChange.add(onLoggedInUserChange);

			// Init.
			registerView(view);
			super.initialize();

			activePaintingModel.onUpdate.add(updateMenu);
		}



		private function onLoggedInUserChange():void
		{
			updateMenu();
		}

		private function onViewSetUp() : void
		{
			updateMenu();
		}

		override public function destroy() : void
		{
			loggedInUser.onChange.remove(onLoggedInUserChange);
			activePaintingModel.onUpdate.remove(updateMenu);
			super.destroy();
		}

		private function updateMenu() : void
		{
//			trace("GPSNVM - updateMenu()");
//			trace("LOOKING AT NEW PAINTING, user: " + activePaintingModel.painting.userID);
//			trace("BEING: " + loggedInUser.userID);

			if (!activePaintingModel.painting || activePaintingModel.painting.collectionType == GalleryType.NONE)
				showButtons(false);
			else {
				showButtons(true);
				updateLoveButton();
				updateShareButton();
				updateUserProfileButton();

				var showLove:Boolean = activePaintingModel.painting.userID != loggedInUser.userID;
//				trace("show love button: " + showLove);
				view.setButtonVisibilityWithID(GalleryPaintingSubNavView.ID_LOVE, showLove);
			}
		}

		private function showButtons(visible : Boolean) : void
		{
			view.setButtonVisibilityWithID(GalleryPaintingSubNavView.ID_SHARE, visible);
			view.setButtonVisibilityWithID(GalleryPaintingSubNavView.ID_LOVE, visible);
			view.getRightButton().visible = visible;
		}

		private function updateShareButton():void
		{
			var painting : GalleryImageProxy = activePaintingModel.painting;
			if (view&&painting) view.enableButtonWithId(GalleryPaintingSubNavView.ID_SHARE, painting.collectionType != GalleryType.NONE);
		}

		private function updateUserProfileButton():void
		{
			var painting : GalleryImageProxy = activePaintingModel.painting;
			if (painting) {
				view.setUserProfile(painting.userName, painting.userThumbnailURL);
				view.getRightButton().visible = painting.collectionType != GalleryType.NONE;
			}
			else {
				view.getRightButton().visible = false;
			}
		}

		private function updateLoveButton() : void
		{
			var painting : GalleryImageProxy = activePaintingModel.painting;

			if (painting) {
				view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, painting.collectionType != GalleryType.NONE);
				var label : String = !loggedInUser.isLoggedIn() || (!painting.isFavorited && painting.userID != loggedInUser.userID)? "LOVE" : "UNLOVE";
				var icon:String = (label=="UNLOVE") ? ButtonIconType.LOVED : ButtonIconType.LOVE;
				view.relabelButtonWithId(GalleryPaintingSubNavView.ID_LOVE, label,icon);
				view.setLoveCount(painting.numLikes);
			}
			else {
				view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, false);
				view.setLoveCount(0);
			}
		}

		override protected function onButtonClicked(id : String) : void
		{
			switch (id) {
//				case GalleryBrowseSubNavView.ID_BACK:
//					goBack();
//					break;
				case GalleryPaintingSubNavView.ID_LOVE:
					if (loggedInUser.isLoggedIn())
						lovePainting();
					else
						showLogIn();
					break;
				case GalleryPaintingSubNavView.ID_SHARE:
					if (loggedInUser.isLoggedIn())
						sharePainting();
					else
						showLogIn();
					break;
				case GalleryPaintingSubNavView.ID_COMMENT:
					if (loggedInUser.isLoggedIn())
						commentOnPainting();
					else
						showLogIn();
					break;
				case GalleryPaintingSubNavView.PROFILE:
					galleryService.targetUserID = activePaintingModel.painting.userID;
					requestNavigationStateChange(NavigationStateType.GALLERY_BROWSE_USER);
					break;
			}
		}

		private function showLogIn():void
		{
			requestShowPopUpSignal.dispatch(PopUpType.LOGIN);
		}

		private function sharePainting() : void
		{
			// Trigger native sharing pop up.
			if(GoViral.isSupported()) {
				if(socialSharingManager.goViral.isGenericShareAvailable()) {
					// Get the image for sharing...
					activePaintingModel.painting.loadFullSizedComposite(onBmdRetrieved, onBmdError);
				}
				else {
					Alert.show("Psykopaint requires iOS 7  for sharing.");
				}
			}
			else {
				Alert.show("GoViral not available.");
			}

			// TODO: THIS NEEDS TO BE CLEANED UP AND TOTALLY REMOVED FROM THE APP, CODE + ASSETS
//			requestNavigationStateChange(NavigationStateType.GALLERY_SHARE);
		}

		private function onBmdError():void {
			Alert.show("Oops! There was a problem sharing this image.");
		}

		private function onBmdRetrieved(bmd:BitmapData):void {
//			trace("bmd retrieved: " + bmd.width + ", " + bmd.height);
			socialSharingManager.goViral.shareGenericMessageWithImage("subject", "Check out this awesome Psykopaint painting by " + activePaintingModel.painting.userName + ".", false, bmd,
									view.stage.mouseX / CoreSettings.GLOBAL_SCALING, view.stage.mouseY / CoreSettings.GLOBAL_SCALING);
		}

		private function commentOnPainting():void
		{
			// TODO: Maybe comment should be a pop-up?
			requestNavigationStateChange(NavigationStateType.GALLERY_SHARE);
		}

		private function goBack() : void
		{
			requestNavigationStateChange(NavigationStateType.HOME_ON_EASEL);
		}

		private function lovePainting() : void
		{
			var painting : GalleryImageProxy = activePaintingModel.painting;
			view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, false);
			painting.isFavorited = !painting.isFavorited;
			updateLoveButton();

			if (painting.isFavorited)
				galleryService.favorite(painting.id, onLovePaintingSucceeded, onLovePaintingFailed);
			else
				galleryService.unfavorite(painting.id, onLovePaintingSucceeded, onLovePaintingFailed);
		}

		private function onLovePaintingSucceeded() : void
		{
			view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, true);
			// put here just in case we want to give feedback in the button
		}

		private function onLovePaintingFailed(amfErrorCode : uint) : void
		{
			// TODO: Display whoops message

			// do not simply set to true, you never know...
			updateLoveButton();
		}
	}
}
