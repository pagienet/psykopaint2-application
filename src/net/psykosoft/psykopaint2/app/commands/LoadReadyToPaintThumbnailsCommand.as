package net.psykosoft.psykopaint2.app.commands
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.service.images.LoadPackagedImagesService;

	public class LoadReadyToPaintThumbnailsCommand
	{
		[Inject]
		public var loadPackagedImagesService:LoadPackagedImagesService;

		public function execute() : void {
			Cc.log( this );
			loadPackagedImagesService.loadThumbnails(
					"ready-to-paint/ready-to-paint.png",
					"ready-to-paint/ready-to-paint.xml"
			);
		}
	}
}
