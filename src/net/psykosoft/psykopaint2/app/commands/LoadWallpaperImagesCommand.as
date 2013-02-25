package net.psykosoft.psykopaint2.app.commands
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.service.packagedimages.LoadWallpaperImagesService;

	public class LoadWallpaperImagesCommand
	{
		[Inject]
		public var wallpapersService:LoadWallpaperImagesService;

		public function execute():void {
			Cc.log( this );
			wallpapersService.loadThumbs();
		}
	}
}
