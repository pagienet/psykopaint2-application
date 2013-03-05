package net.psykosoft.psykopaint2.app.commands
{

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.model.thumbnails.ReadyToPaintThumbnailsModel;

	import net.psykosoft.psykopaint2.app.service.images.LoadPackagedImagesService;

	import robotlegs.bender.framework.api.IContext;

	public class LoadReadyToPaintThumbnailsCommand
	{
		[Inject]
		public var readyToPaintImagesModel:ReadyToPaintThumbnailsModel;

		[Inject]
		public var context:IContext;

		private var _packagedImagesService:LoadPackagedImagesService;

		public function execute() : void {
			Cc.log( this, "executing..." );
			_packagedImagesService = new LoadPackagedImagesService();
			_packagedImagesService.thumbnailsLoadedSignal.add( onThumbnailsLoaded );
			_packagedImagesService.loadThumbnails(
					"assets-packaged/ready-to-paint/ready-to-paint.png",
					"assets-packaged/ready-to-paint/ready-to-paint.xml"
			);
			context.detain( this );
		}

		private function onThumbnailsLoaded( atlas:BitmapData, descriptor:XML ):void {
			_packagedImagesService.thumbnailsLoadedSignal.remove( onThumbnailsLoaded );
			Cc.log( this, "onThumbnailsLoaded - atlas: " + atlas + ", descriptor: " + descriptor );
			readyToPaintImagesModel.setThumbnails( atlas, descriptor );
			context.release( this );
		}
	}
}
