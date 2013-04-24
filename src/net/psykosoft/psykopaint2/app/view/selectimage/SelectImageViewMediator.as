package net.psykosoft.psykopaint2.app.view.selectimage
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.types.ImageSourceType;
	import net.psykosoft.psykopaint2.app.service.images.ANEIOSImageService;
	import net.psykosoft.psykopaint2.app.service.images.DesktopImageService;
	import net.psykosoft.psykopaint2.app.service.images.FacebookImageService;
	import net.psykosoft.psykopaint2.app.service.images.IImageService;
	import net.psykosoft.psykopaint2.app.service.images.LoadPackagedImagesService;
	import net.psykosoft.psykopaint2.app.service.images.NativeIOSImageService;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyLoadImageSourceRequestedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestSourceImageChangeSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	import starling.textures.TextureAtlas;

	public class SelectImageViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var selectImageView:SelectImageView;

		[Inject]
		public var notifyLoadImageSourceRequestedSignal:NotifyLoadImageSourceRequestedSignal;

		[Inject]
		public var requestSourceImageChangeSignal:RequestSourceImageChangeSignal;

		private var _imageService:IImageService;

		override public function initialize():void {

			super.initialize();
			registerView( selectImageView );
			registerEnablingState( ApplicationStateType.PAINTING_SELECT_IMAGE_CHOOSING );

			// From view.
			selectImageView.listSelectedItemChangedSignal.add( onListItemSelected );

			// From app.
			notifyLoadImageSourceRequestedSignal.add( onLoadImageRequested );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onListItemSelected( itemName:String ):void {
			_imageService.loadFullImage( itemName );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onLoadImageRequested( sourceType:String ):void {
			trace( this, "image sources requested for: " + sourceType );
			switch( sourceType ) {

				case ImageSourceType.FACEBOOK:
						_imageService = new FacebookImageService();
						_imageService.getThumbnailsLoadedSignal().add( onThumbnailsLoaded );
						_imageService.loadThumbnails();
					break;

				case ImageSourceType.READY_TO_PAINT:
						_imageService = new LoadPackagedImagesService();
						LoadPackagedImagesService( _imageService ).imageUrl = "assets-packaged/ready-to-paint/ready-to-paint.png";
						LoadPackagedImagesService( _imageService ).xmlUrl = "assets-packaged/ready-to-paint/ready-to-paint.xml";
						LoadPackagedImagesService( _imageService ).originalImagesPath = "assets-packaged/ready-to-paint/originals/";
						_imageService.getThumbnailsLoadedSignal().add( onThumbnailsLoaded );
						_imageService.getFullImageLoadedSignal().add( onFullImageLoaded );
						_imageService.loadThumbnails();
					break;

				case ImageSourceType.IOS_USER_PHOTOS_NATIVE:
						_imageService = new NativeIOSImageService();
						_imageService.getFullImageLoadedSignal().add( onFullImageLoaded );
						_imageService.loadFullImage( "prompt" );
					break;

				case ImageSourceType.IOS_USER_PHOTOS_ANE:
						_imageService = new ANEIOSImageService();
						_imageService.getThumbnailsLoadedSignal().add( onThumbnailsLoaded );
						_imageService.getFullImageLoadedSignal().add( onFullImageLoaded );
						_imageService.loadThumbnails();
					break;

				case ImageSourceType.DESKTOP:
						_imageService = new DesktopImageService();
						_imageService.getFullImageLoadedSignal().add( onFullImageLoaded );
						_imageService.loadFullImage( "prompt" );
					break;
			}
		}

		private function onFullImageLoaded( bmd:BitmapData ):void {
			trace( this, "onFullImageLoaded - image: " + bmd );

			// Notify the drawing core of the selected image.
			requestSourceImageChangeSignal.dispatch( bmd );

			// Dispose service.
			_imageService.disposeService(); // TODO: service should also be disposed if the user cancels the selection in some way
			_imageService = null;

			// Kill view.
			selectImageView.disable();
		}

		private function onThumbnailsLoaded( atlas:TextureAtlas ):void {
			trace( this, "onThumbnailsLoaded - atlas: " + atlas );
			selectImageView.displayThumbs( atlas );
		}
	}
}
