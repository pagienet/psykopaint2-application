package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.model.StateModel;

	import org.swiftsuspenders.Injector;

	public class ModelsConfig
	{
		public function ModelsConfig( injector:Injector ) {

			injector.map( StateModel ).asSingleton();

		}
	}
}
