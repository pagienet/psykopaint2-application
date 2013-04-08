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

		public function FacebookImageService() {
			trace( this );
			super();
			_imageLoadedSignal = new Signal();
			_thumbnailsLoadedSignal = new Signal();
		}

		public function loadThumbnails():void {
			trace( this, "loadThumbnails()" );
			//FIRST TIME WE NEED TO CONNECT THE SERVICE
			connectService();
		}

		private function connectService():void {

			//TODO: THIS STUFF WILL HAVE TO BE CENTRALISED SOMEWHERE ELSE

			if( GoViral.isSupported() ) {
				trace( this, "GoViral - Creating..." );
				GoViral.create();
				GoViral.goViral.addEventListener( GVFacebookEvent.FB_DIALOG_CANCELED, onFacebookEvent );
				GoViral.goViral.addEventListener( GVFacebookEvent.FB_DIALOG_FAILED, onFacebookEvent );
				GoViral.goViral.addEventListener( GVFacebookEvent.FB_DIALOG_FINISHED, onFacebookEvent );
				GoViral.goViral.addEventListener( GVFacebookEvent.FB_LOGGED_IN, onFacebookEvent );
				GoViral.goViral.addEventListener( GVFacebookEvent.FB_LOGGED_OUT, onFacebookEvent );
				GoViral.goViral.addEventListener( GVFacebookEvent.FB_LOGIN_CANCELED, onFacebookEvent );
				GoViral.goViral.addEventListener( GVFacebookEvent.FB_LOGIN_FAILED, onFacebookEvent );
				GoViral.goViral.addEventListener( GVFacebookEvent.FB_REQUEST_FAILED, onFacebookEvent );
				GoViral.goViral.addEventListener( GVFacebookEvent.FB_REQUEST_RESPONSE, onFacebookEvent );
			}
			else {
				trace( this, "Facebook Connect only works on iOS!" );
				return;
			}

			trace( this, "GoViral - initializing..." );
			GoViral.goViral.initFacebook( "503384473059408", "" );

			// If the user is not already logged in...
			if( !GoViral.goViral.isFacebookAuthenticated() ) {
				// show a connect with Facebook prompt. 
				// This method takes a comma separated list of facebook READ
				// permissions as a first parameter, and a comma-separated list of
				// Facebook WRITE permissions as a second parameter.
				// You can refer to the facebook documentation at
				// http://developers.facebook.com/docs/authentication/permissions/  
				// to determine which permissions your app requires.
				trace( this, "User is not authenticated. Authenticating..." );
				GoViral.goViral.authenticateWithFacebook( "'email,user_photos','publish_actions,publish_stream'" );
				//
			} else {
				trace( this, "User is authenticated." );
			}
		}

		protected function onFacebookEvent( event:Event ):void {
			trace( this, "onFacebookEvent: " + event.type );
			if( event.type == GVFacebookEvent.FB_LOGGED_IN ) {
				trace( this, "Dude is logged in" );
				getUsersPhotos();
			}
			if( event.type == GVFacebookEvent.FB_LOGIN_FAILED ) {
				// TODO: sometimes if the user is logged in the facebook app, but his credentials
				// TODO: are not registered in settings, a weird error will show up on the facebook app, which is confusing
				// TODO: we should notify the user that this may be happening, he needs to set up his credentials in settings
				// TODO: note, he also has to authorize the app in settings for access
				trace( this, "Dude failed to login" );
			}
			if( event.type == GVFacebookEvent.FB_LOGIN_CANCELED ) {
				trace( this, "Dude changed his mind" );
			}
			if( event.type == GVFacebookEvent.FB_REQUEST_RESPONSE ) {
			}
		}

		private function getUsersPhotos():void {
			callFacebookGraphRequest( "me/albums", function ( albumsData:Object ) {
				var facebookAlbumsFeed:Object = Object( albumsData ).data;

				//GET ALL ALBUMS
				var albumIDs:Array = [];
				// TODO...
				/*for (var i:int in facebookAlbumsFeed){

				 trace("facebookAlbumsFeed[i].id = "+facebookAlbumsFeed[i].id);
				 albumIDs.push(facebookAlbumsFeed[i].id);


				 }*/
				//GET FIRST ALBUM - RECURSIVE CALL TO OTHERS
				getAlbumPhotos( albumIDs, 0 );

			} );

		}

		private function getAlbumPhotos( albumIDs:Array, currentIndex:int ):void {
			//GET PHOTOS FROM  ALBUM
			callFacebookGraphRequest( albumIDs[currentIndex] + "/photos", function ( albumPhotosData:Object ) {

				trace( this, "currentAlbumPhotos = " + JSON.stringify( (albumPhotosData) ) );

				var currentAlbumPhotos:Object = Object( albumPhotosData ).data;
				// TODO...
				/*for (var j:int in currentAlbumPhotos){

				 //index 8 is the smallest size thumbnail with biggest size at 75px
				 trace("currentPhoto = "+currentAlbumPhotos[j].images[8].source);

				 //Taking picture is the thumbnail size
				 //trace("currentPhoto = "+currentAlbumPhotos[j].picture);
				 }*/

				//GET NEXT ALBUM
				if( currentIndex < albumIDs.length )
					getAlbumPhotos( albumIDs, currentIndex + 1 );

				//throw new Error("debug");
			} )
		}


		//CALL FACEBOOK GRAPH AND PASS THE RETURN OBJECT AS PARAMETER TO CALLBACK
		private function callFacebookGraphRequest( graphCall:String, onFinished:Function ):void {
			GoViral.goViral.facebookGraphRequest( graphCall, GVHttpMethod.GET, null );
			GoViral.goViral.addEventListener( GVFacebookEvent.FB_REQUEST_RESPONSE, onFacebookCall );
			function onFacebookCall( e:GVFacebookEvent ):void {
				GoViral.goViral.removeEventListener( GVFacebookEvent.FB_REQUEST_RESPONSE, onFacebookCall );

				onFinished.call( null, e.data );

			}
		}


		public function loadFullImage( id:String ):void {
			// TODO...
		}

		public function getFullImageLoadedSignal():Signal {
			return _imageLoadedSignal;
		}

		public function getThumbnailsLoadedSignal():Signal {
			return _thumbnailsLoadedSignal;
		}

		public function disposeService():void {
			// TODO!
			// TODO: remove go viral listeners, if this service is created again, createGoViral() might not be called and the listeners may not be attached
			// TODO: there might be a way to destroy GoViral
		}
	}
}