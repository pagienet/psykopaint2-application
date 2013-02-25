package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.model.packagedimages.SourceImagesModel;
	import net.psykosoft.psykopaint2.app.model.packagedimages.WallpapersModel;
	import net.psykosoft.psykopaint2.app.model.state.StateModel;

	import org.swiftsuspenders.Injector;

	public class ModelsConfig
	{
		public function ModelsConfig( injector:Injector ) {

			injector.map( StateModel ).asSingleton();
			injector.map( SourceImagesModel ).asSingleton();
			injector.map( WallpapersModel ).asSingleton();

		}
	}
}
