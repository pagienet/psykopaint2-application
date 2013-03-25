package net.psykosoft.psykopaint2.app.model
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.service.images.IImageService;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestSourceImageChangeSignal;

	public class FullImageModel
	{
		[Inject]
		public var requestSourceImageChangeSignal:RequestSourceImageChangeSignal;

		private var _imageService:IImageService;

		public function FullImageModel() {
			super();
		}

		public function setService( imageService:IImageService ):void {
			_imageService = imageService;
		}

		public function loadFullImage( imageId:String ):void {
			_imageService.getFullImageLoadedSignal().add( setFullImage );
			_imageService.loadFullImage( imageId );
		}

		public function setFullImage( bmd:BitmapData ):void {
			requestSourceImageChangeSignal.dispatch( bmd );
			_imageService.disposeService();
			_imageService = null;
		}
	}
}
