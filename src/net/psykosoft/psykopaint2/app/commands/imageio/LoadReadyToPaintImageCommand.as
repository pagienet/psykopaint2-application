package net.psykosoft.psykopaint2.app.commands.imageio
{

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.model.thumbnails.ThumbnailsModel;

	import net.psykosoft.psykopaint2.app.service.images.LoadPackagedImagesService;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestSourceImageChangeSignal;

	import robotlegs.bender.framework.api.IContext;

	public class LoadReadyToPaintImageCommand
	{
		[Inject]
		public var imageName:String;

		[Inject]
		public var requestSourceImageChangeSignal:RequestSourceImageChangeSignal;

		[Inject]
		public var readyToPaintImagesModel:ThumbnailsModel;

		[Inject]
		public var context:IContext;

		private var _packagedImagesService:LoadPackagedImagesService;

		public function execute() : void {
			Cc.log( this, "executing..." );
			_packagedImagesService = new LoadPackagedImagesService();
			_packagedImagesService.imageLoadedSignal.add( onImageLoaded );
			_packagedImagesService.imageUrl = "assets-packaged/ready-to-paint/originals/" + imageName + ".jpg";
			_packagedImagesService.loadFullImage();
			context.detain( this );
		}

		private function onImageLoaded( image:BitmapData ):void {
			_packagedImagesService.imageLoadedSignal.remove( onImageLoaded );
			Cc.log( this, "onImageLoaded - image: " + image );
			requestSourceImageChangeSignal.dispatch( image );
			readyToPaintImagesModel.dispose();
			context.release( this );
		}
	}
}
