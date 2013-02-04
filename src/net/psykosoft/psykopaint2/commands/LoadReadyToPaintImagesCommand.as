package net.psykosoft.psykopaint2.commands
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.service.packagedimages.LoadReadyToPaintImagesService;

	public class LoadReadyToPaintImagesCommand
	{
		[Inject]
		public var loadReadyToPaintImagesService:LoadReadyToPaintImagesService;

		public function execute() : void {

			Cc.log( this );

			// TODO: check if images already loaded

			loadReadyToPaintImagesService.loadThumbs();
		}
	}
}
