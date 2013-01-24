package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.model.CanvasModel;
	import net.psykosoft.psykopaint2.model.packagedimages.SourceImagesModel;
	import net.psykosoft.psykopaint2.model.packagedimages.WallpapersModel;
	import net.psykosoft.psykopaint2.model.state.StateModel;

	import org.swiftsuspenders.Injector;

	public class ModelsConfig
	{
		public function ModelsConfig( injector:Injector ) {

			injector.map( StateModel ).asSingleton();
			injector.map( SourceImagesModel ).asSingleton();
			injector.map( WallpapersModel ).asSingleton();
			injector.map( CanvasModel ).asSingleton();
		}
	}
}
