package net.psykosoft.psykopaint2.home.views.gallery
{
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import net.psykosoft.psykopaint2.base.utils.alert.Alert;
	import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;
	import net.psykosoft.psykopaint2.core.managers.social.sharers.FacebookSharer;
	import net.psykosoft.psykopaint2.core.models.FileGalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateErrorPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;

	public class GalleryShareSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view : GalleryShareSubNavView;

		
		[Inject]
		public var socialSharingManager:SocialSharingManager;
		
		[Inject]
		public var activePaintingModel : ActiveGalleryPaintingModel;
		
		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;
		
		[Inject]
		public var requestUpdateErrorPopUpSignal:RequestUpdateErrorPopUpSignal;
		
		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;


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
				case GalleryShareSubNavView.ID_BACK:
					goBack();
					break;
				case GalleryShareSubNavView.ID_EMAIL:
					if(GoViral.isSupported()) {
						if(socialSharingManager.goViral.isEmailAvailable()) {
							// Get the image for sharing...
							FileGalleryImageProxy(activePaintingModel.painting).fullsizeURL;
							socialSharingManager.goViral.showEmailComposer("Check this painting","","By "+FileGalleryImageProxy(activePaintingModel.painting).userName+"<br><img width='100%' height='100%' src='"+FileGalleryImageProxy(activePaintingModel.painting).fullsizeURL+"'>",true);
						}
						else {
							Alert.show("Psykopaint requires iOS 7 for sharing. Sorry buddy");
						}
					}
					else {
						Alert.show("Oups. Seems like Sharing is not available on this iPad. Try updating iOS.");
						trace("Go Viral is not available");
						
					}
					break;
				case GalleryShareSubNavView.ID_FACEBOOK:
					if(GoViral.isSupported()) {
						if(socialSharingManager.goViral.isFacebookSupported()) {
							// Get the image for sharing...
							trace("Sharing on facebook...");
							var facebookSharer:FacebookSharer = new FacebookSharer(socialSharingManager);
							var imageLoader:Loader = new Loader();
							imageLoader.load(new URLRequest(FileGalleryImageProxy(activePaintingModel.painting).fullsizeURL));
							imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeFacebookHandler);
							
							requestShowPopUpSignal.dispatch( PopUpType.MESSAGE );
							requestUpdateMessagePopUpSignal.dispatch( "Posting on Facebook...", "Give us a second, we upload the image to Facebook" );
							
							
							function completeFacebookHandler(e:Event):void{
								
								//socialSharingManager.goViral.showTweetSheetWithImage("Check this painting by "+FileGalleryImageProxy(activePaintingModel.painting).userName+" "+FileGalleryImageProxy(activePaintingModel.painting).fullsizeURL+" @Psykopaint",Bitmap(imageLoader.content).bitmapData);
								
								facebookSharer.share(["Painting by "+FileGalleryImageProxy(activePaintingModel.painting).userName,Bitmap(imageLoader.content).bitmapData]);
								imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeFacebookHandler);
								
								imageLoader.unload();
								imageLoader = null;
								
								//HIDE BUTTON
								view.setButtonVisibilityWithID(GalleryShareSubNavView.ID_FACEBOOK,false);
								
								
								//SHOW POPUP
								requestShowPopUpSignal.dispatch( PopUpType.ERROR );
								requestUpdateErrorPopUpSignal.dispatch( "Posted on Facebook", "Yep it's done already. It's that fast!<br>Check your Facebook feed in a bit" );
							}
							
						}
						else {
							Alert.show("Psykopaint requires iOS 7 for sharing. Sorry buddy");
						}
					}
					else {
						Alert.show("Oups. Seems like Sharing is not available on this iPad. Try updating iOS.");
						trace("Go Viral is not available");
						
					}
					break;
				case GalleryShareSubNavView.ID_TWITTER:
					
					
					if(GoViral.isSupported()) {
						if(socialSharingManager.goViral.isTweetSheetAvailable()) {
							var imageLoader:Loader = new Loader();
							imageLoader.load(new URLRequest(FileGalleryImageProxy(activePaintingModel.painting).mediumSizeURL));
							imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
							function completeHandler(e:Event):void{
								
								socialSharingManager.goViral.showTweetSheetWithImage("Check this painting by "+FileGalleryImageProxy(activePaintingModel.painting).userName+" "+FileGalleryImageProxy(activePaintingModel.painting).fullsizeURL+" @Psykopaint",Bitmap(imageLoader.content).bitmapData);
								imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);

								imageLoader.unload();
								imageLoader = null;
							}
								
							// Get the image for sharing...
							//FileGalleryImageProxy(activePaintingModel.painting).fullsizeURL;
							//socialSharingManager.goViral.showTweetSheet("Check this painting by "+FileGalleryImageProxy(activePaintingModel.painting).userName+" "+FileGalleryImageProxy(activePaintingModel.painting).fullsizeURL+" @Psykopaint");
						}
						else {
							Alert.show("Psykopaint requires iOS 7 for sharing. Sorry buddy");
						}
					}
					else {
						Alert.show("Oups. Seems like Sharing is not available on this iPad. Try updating iOS.");
						trace("Go Viral is not available");
						
					}
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
