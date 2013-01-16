package net.psykosoft.psykopaint2.commands
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.service.packagedimages.LoadWallpaperImagesService;

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
