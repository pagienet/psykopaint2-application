package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.model.ActivePaintingModel;
	import net.psykosoft.psykopaint2.app.model.StateModel;

	import org.swiftsuspenders.Injector;

	public class ModelsConfig
	{
		public function ModelsConfig( injector:Injector ) {

			injector.map( StateModel ).asSingleton();
			injector.map( ActivePaintingModel ).asSingleton();

		}
	}
}
