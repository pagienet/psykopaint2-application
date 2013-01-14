package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.service.sourceimages.readytopaint.LoadReadyToPaintImagesService;

	import org.swiftsuspenders.Injector;

	public class ServicesConfig
	{
		public function ServicesConfig( injector:Injector ) {

			// Platform independent.
			injector.map( LoadReadyToPaintImagesService ).asSingleton();

			// Platform dependent.
//			injector.map( SampleServiceInterface ).toSingleton( SampleServiceImplementation );

		}
	}
}
