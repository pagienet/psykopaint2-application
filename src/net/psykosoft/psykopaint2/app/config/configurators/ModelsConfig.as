package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.model.state.StateModel;
	import net.psykosoft.psykopaint2.app.model.thumbnails.ReadyToPaintThumbnailsModel;

	import org.swiftsuspenders.Injector;

	public class ModelsConfig
	{
		public function ModelsConfig( injector:Injector ) {

			injector.map( StateModel ).asSingleton();
			injector.map( ReadyToPaintThumbnailsModel ).asSingleton();
//			injector.map( WallpapersModel ).asSingleton();

		}
	}
}
