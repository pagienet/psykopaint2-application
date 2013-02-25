package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.controller.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.app.controller.gestures.GestureManager;

	import org.swiftsuspenders.Injector;

	public class SingletonsConfig
	{
		public function SingletonsConfig( injector:Injector ) {
			injector.map( GestureManager ).asSingleton();
			injector.map( AccelerometerManager ).asSingleton();
		}
	}
}
