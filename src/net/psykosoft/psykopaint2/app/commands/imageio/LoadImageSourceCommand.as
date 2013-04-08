package net.psykosoft.psykopaint2.app.commands.imageio
{

	import com.junkbyte.console.Cc;
	
	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.app.data.types.ImageSourceType;
	import net.psykosoft.psykopaint2.app.model.FullImageModel;
	import net.psykosoft.psykopaint2.app.model.ThumbnailsModel;
	import net.psykosoft.psykopaint2.app.service.images.ANEIOSImageService;
	import net.psykosoft.psykopaint2.app.service.images.DesktopImageService;
	import net.psykosoft.psykopaint2.app.service.images.FacebookImageService;
	import net.psykosoft.psykopaint2.app.service.images.IImageService;
	import net.psykosoft.psykopaint2.app.service.images.LoadPackagedImagesService;
	import net.psykosoft.psykopaint2.app.service.images.NativeIOSImageService;
	
	import robotlegs.bender.framework.api.IContext;
	
	import starling.textures.TextureAtlas;

	/*
	* Initiates an async image selection process that may query the user to
	* pick an image from a source of thumbnails, the operating system, etc.
	* */
	public class LoadImageSourceCommand
	{
		[Inject]
		public var sourceType:String;

		[Inject]
		public var thumbnailsModel:ThumbnailsModel;

		[Inject]
		public var fullImageModel:FullImageModel;

		[Inject]
		public var context:IContext;

		private var _imageService:IImageService;

		public function execute() : void {

			Cc.log( this, "executing..." );

			switch( sourceType ) {

				case ImageSourceType.FACEBOOK:
						//throw new Error( this, "cannot retrieve thumbnails from this source yet: " + sourceType );
						_imageService = new FacebookImageService();
						_imageService.getThumbnailsLoadedSignal().add( onThumbnailsLoaded );
						_imageService.loadThumbnails( );	
					break;

				case ImageSourceType.READY_TO_PAINT:
						_imageService = new LoadPackagedImagesService();
						LoadPackagedImagesService( _imageService ).imageUrl = "assets-packaged/ready-to-paint/ready-to-paint.png";
						LoadPackagedImagesService( _imageService ).xmlUrl = "assets-packaged/ready-to-paint/ready-to-paint.xml";
						LoadPackagedImagesService( _imageService ).originalImagesPath = "assets-packaged/ready-to-paint/originals/";
						_imageService.getThumbnailsLoadedSignal().add( onThumbnailsLoaded );
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
						_imageService.loadThumbnails();
					break;

				case ImageSourceType.DESKTOP:
						_imageService = new DesktopImageService();
						_imageService.getFullImageLoadedSignal().add( onFullImageLoaded );
						_imageService.loadFullImage( "prompt" );
					break;

			}

			fullImageModel.setService( _imageService );
			context.detain( this );
		}

		private function onFullImageLoaded( bmd:BitmapData ):void {
			Cc.log( this, "onFullImageLoaded - image: " + bmd );
			_imageService.getFullImageLoadedSignal().remove( onFullImageLoaded );
			fullImageModel.setFullImage( bmd );
		}

		private function onThumbnailsLoaded( atlas:TextureAtlas ):void {
			Cc.log( this, "onThumbnailsLoaded - atlas: " + atlas );
//			_imageService.getThumbnailsLoadedSignal().remove( onThumbnailsLoaded );
			thumbnailsModel.setThumbnails( atlas );
			context.release( this );
		}
	}
}
