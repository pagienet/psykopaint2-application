package net.psykosoft.psykopaint2.app.commands.imageio
{

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.data.types.ImageSourceType;
	import net.psykosoft.psykopaint2.app.model.FullImageModel;

	import net.psykosoft.psykopaint2.app.model.ThumbnailsModel;
	import net.psykosoft.psykopaint2.app.service.images.IImageService;

	import net.psykosoft.psykopaint2.app.service.images.LoadPackagedImagesService;

	import robotlegs.bender.framework.api.IContext;

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

						throw new Error( this, "cannot retrieve thumbnails from this source yet: " + sourceType );

					break;

				case ImageSourceType.READY_TO_PAINT:

						_imageService = new LoadPackagedImagesService();
						LoadPackagedImagesService( _imageService ).imageUrl = "assets-packaged/ready-to-paint/ready-to-paint.png";
						LoadPackagedImagesService( _imageService ).xmlUrl = "assets-packaged/ready-to-paint/ready-to-paint.xml";
						LoadPackagedImagesService( _imageService ).originalImagesPath = "assets-packaged/ready-to-paint/originals/";

					break;

				case ImageSourceType.IOS_NATIVE_USER_PHOTOS:

						throw new Error( this, "cannot retrieve images from this source yet: " + sourceType );

					break;

			}

			fullImageModel.setService( _imageService );
			_imageService.getThumbnailsLoadedSignal().add( onThumbnailsLoaded );
			_imageService.loadThumbnails();

			context.detain( this );
		}

		private function onThumbnailsLoaded( atlas:BitmapData, descriptor:XML ):void {

			Cc.log( this, "onThumbnailsLoaded - atlas: " + atlas + ", descriptor: " + descriptor );

			_imageService.getThumbnailsLoadedSignal().remove( onThumbnailsLoaded );

			thumbnailsModel.setThumbnails( atlas, descriptor );

			context.release( this );
		}
	}
}
