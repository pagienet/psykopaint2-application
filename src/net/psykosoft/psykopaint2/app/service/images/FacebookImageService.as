package net.psykosoft.psykopaint2.app.service.images
{
	import com.milkmangames.nativeextensions.GVHttpMethod;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
		
	public class FacebookImageService implements IImageService
	{
		private var _imageLoadedSignal:Signal;
		private var _thumbnailsLoadedSignal:Signal;
		
		public var imageUrl:String;
		public var xmlUrl:String;
		
		public function FacebookImageService()
		{
			super();
			_imageLoadedSignal = new Signal();
			_thumbnailsLoadedSignal = new Signal();
		}
		
		public function loadThumbnails():void
		{
			//FIRST TIME WE NEED TO CONNECT THE SERVICE
				connectService();
		}
		
		private function connectService():void
		{
			//TODO: THIS STUFF WILL HAVE TO BE CENTRALISED SOMEWHERE ELSE
			
			if(GoViral.isSupported())
			{
				trace("[FacebookImageService] Goviral Create");
				GoViral.create();
				trace("[FacebookImageService] Goviral Created");
			}
			else {
				trace("Facebook Connect only works on iOS!");
				return;
			}
			trace("[FacebookImageService] initFacebook");
			trace(GoViral.goViral.initFacebook("503384473059408",""));
			trace("[FacebookImageService] Init facebook Done");

			//CREATE GOVIRAL EVENTS
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN, onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_OUT, onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFacebookEvent);
			
			
			
			
			
			// If the user is not already logged in...
			if(!GoViral.goViral.isFacebookAuthenticated())
			{
				// show a connect with Facebook prompt. 
				// This method takes a comma separated list of facebook READ
				// permissions as a first parameter, and a comma-separated list of
				// Facebook WRITE permissions as a second parameter.
				// You can refer to the facebook documentation at
				// http://developers.facebook.com/docs/authentication/permissions/  
				// to determine which permissions your app requires.
				trace("[FacebookImageService] User is not authenticated. Authenticate");

				GoViral.goViral.authenticateWithFacebook("'email,user_photos','publish_actions,publish_stream'");
				//
			}else {
				trace("[FacebookImageService] User is authenticated.");

			}
			
			
			
		}
		
		protected function onFacebookEvent(event:Event):void
		{
			//trace("[FacebookImageService]  onFacebookEvent = "+event.type);
			if(event.type==GVFacebookEvent.FB_LOGGED_IN){
				trace("Dude is logged in");
				getUsersPhotos();
				
			}
			if(event.type==GVFacebookEvent.FB_LOGIN_FAILED){
				throw new Error("Dude failed to login");
			}
			if(event.type==GVFacebookEvent.FB_LOGIN_CANCELED){
				throw new Error("Dude changed his mind");
			}
			if(event.type==GVFacebookEvent.FB_REQUEST_RESPONSE){
			}
		}
			
		
		private function getUsersPhotos():void{
			callFacebookGraphRequest("me/albums",function(albumsData:Object){
				var facebookAlbumsFeed:Object = Object(albumsData).data;
				
				//GET ALL ALBUMS
				var albumIDs:Array = [];
				for (var i:int in facebookAlbumsFeed){
					
					trace("facebookAlbumsFeed[i].id = "+facebookAlbumsFeed[i].id);
					albumIDs.push(facebookAlbumsFeed[i].id);
					
					
				}
				//GET FIRST ALBUM - RECURSIVE CALL TO OTHERS
				getAlbumPhotos(albumIDs,0);
				
			});
			
		}	
	
		private function getAlbumPhotos(albumIDs:Array,currentIndex:int):void{
			//GET PHOTOS FROM  ALBUM
			callFacebookGraphRequest(albumIDs[currentIndex]+"/photos",function(albumPhotosData:Object){
				
				trace("currentAlbumPhotos = "+JSON.stringify((albumPhotosData)));
				
				var currentAlbumPhotos:Object = Object(albumPhotosData).data;
				for (var j:int in currentAlbumPhotos){
					
					//index 8 is the smallest size thumbnail with biggest size at 75px
					trace("currentPhoto = "+currentAlbumPhotos[j].images[8].source);
					
					//Taking picture is the thumbnail size
					//trace("currentPhoto = "+currentAlbumPhotos[j].picture);
				}
				
				//GET NEXT ALBUM
				if(currentIndex<albumIDs.length)
				getAlbumPhotos(albumIDs,currentIndex+1);
				
				//throw new Error("debug");
			})
		}
		
		
		
		//CALL FACEBOOK GRAPH AND PASS THE RETURN OBJECT AS PARAMETER TO CALLBACK
		private function callFacebookGraphRequest(graphCall:String,onFinished:Function):void{
			GoViral.goViral.facebookGraphRequest(graphCall,GVHttpMethod.GET,null);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFacebookCall);
			function onFacebookCall(e:GVFacebookEvent):void{
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFacebookCall);

				onFinished.call(null,e.data);

			}
		}
	
		
		public function loadFullImage(id:String):void
		{
		}
		
		public function getFullImageLoadedSignal():Signal {
			return _imageLoadedSignal;
		}
		
		public function getThumbnailsLoadedSignal():Signal {
			return _thumbnailsLoadedSignal;
		}
		
		public function disposeService():void
		{
		}
	}
}