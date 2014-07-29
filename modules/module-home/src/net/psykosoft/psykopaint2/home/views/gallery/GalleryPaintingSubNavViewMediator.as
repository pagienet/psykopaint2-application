package net.psykosoft.psykopaint2.home.views.gallery
{

import flash.display.BitmapData;
import flash.events.MouseEvent;

import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;
import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
import net.psykosoft.psykopaint2.core.models.GalleryType;
import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
import net.psykosoft.psykopaint2.core.models.NavigationStateType;
import net.psykosoft.psykopaint2.core.services.GalleryService;
import net.psykosoft.psykopaint2.core.signals.RequestGalleryReconnectSignal;
import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
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
		public var requestGalleryReconnectSignal : RequestGalleryReconnectSignal;


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

			if (!activePaintingModel.painting || activePaintingModel.painting.collectionType == GalleryType.NONE){
				showButtons(false);
			}else {
				showButtons(true);
				updateLoveButton();
				updateShareButton();
				updateUserProfileButton();

				//LOVE BUTTON VISIBILITY: NO LOVE BUTTON WHEN USER OWN THE PAINTING
				var isUserOwner:Boolean = activePaintingModel.painting.userID == loggedInUser.userID;
				if (isUserOwner){
					//SHOW DELETE BUTTON
					view.updateButtons(true);			
					//MATHIEU HACK TO CENTER SHARE BUTTO UNTIL WE FIX THE WHOLE NAV SYSTEM.
					if(isUserOwner==true){
						view.x = -60;
					}else {
						view.x = 0;
					}
				}else {
					
					//HIDE DELETE BUTTON
					view.updateButtons(false);
				}
				//IF USER IS ADMIN WE SHOW THE DELETE BUTTON TOO
				if(loggedInUser.admin){
					view.updateButtons(true);
				}
				
//				trace("show love button: " + showLove);
				
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
				case GalleryPaintingSubNavView.ID_DELETE:
					if (loggedInUser.isLoggedIn())
						deletePainting();
					else
						showLogIn();
					break;
				case GalleryPaintingSubNavView.ID_SHARE:
						sharePainting();
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
		
		private function deletePainting():void
		{
			var painting : GalleryImageProxy = activePaintingModel.painting;

			galleryService.removePainting(painting.id, onDeletePaintingSucceeded, onDeletePaintingFailed);
		}
		
		private function onDeletePaintingFailed():void
		{
			//SHOW ERROR MESSAGE			
		}
		
		private function onDeletePaintingSucceeded():void
		{
			
			//UPDATE VIEW
			//RESET GALLERY VIEW
			requestGalleryReconnectSignal.dispatch();
		}
		
		private function sharePainting() : void
		{			
				
			requestNavigationStateChange(NavigationStateType.GALLERY_SHARE);
		}

		private function onBmdError():void {
			//Alert.show("Oops! There was a problem sharing this image.");
		}

		private function onBmdRetrieved(bmd:BitmapData):void {
//			trace("bmd retrieved: " + bmd.width + ", " + bmd.height);
			socialSharingManager.goViral.shareGenericMessageWithImage("subject", "Check out this painting by " + activePaintingModel.painting.userName + ".", false, bmd, view.stage.mouseX / CoreSettings.GLOBAL_SCALING, view.stage.mouseY / CoreSettings.GLOBAL_SCALING);
			//						
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
