package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.service.packagedimages.LoadReadyToPaintImagesService;
	import net.psykosoft.psykopaint2.service.packagedimages.LoadWallpaperImagesService;

	import org.swiftsuspenders.Injector;

	public class ServicesConfig
	{
		public function ServicesConfig( injector:Injector ) {

			// Platform independent.
			injector.map( LoadReadyToPaintImagesService ).asSingleton();
			injector.map( LoadWallpaperImagesService ).asSingleton();

			// Platform dependent.
//			injector.map( SampleServiceInterface ).toSingleton( SampleServiceImplementation );

		}
	}
}
