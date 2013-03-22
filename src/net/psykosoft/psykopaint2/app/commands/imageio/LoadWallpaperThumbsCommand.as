package net.psykosoft.psykopaint2.app.commands.imageio
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.service.images.LoadPackagedImagesService;

	public class LoadWallpaperThumbsCommand
	{
		[Inject]
		public var loadPackagedImagesService:LoadPackagedImagesService;

		public function execute() : void {
			Cc.log( this );
			/*loadPackagedImagesService.loadThumbnails(
					"wallpapers/wallpapers.png",
					"wallpapers/wallpapers.xml"
			);*/
		}
	}
}
