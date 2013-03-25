package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.model.FullImageModel;
	import net.psykosoft.psykopaint2.app.model.StateModel;
	import net.psykosoft.psykopaint2.app.model.ThumbnailsModel;

	import org.swiftsuspenders.Injector;

	public class ModelsConfig
	{
		public function ModelsConfig( injector:Injector ) {

			injector.map( StateModel ).asSingleton();
			injector.map( ThumbnailsModel ).asSingleton();
			injector.map( FullImageModel ).asSingleton();
//			injector.map( WallpapersModel ).asSingleton();

		}
	}
}
