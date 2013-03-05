package net.psykosoft.psykopaint2.app.config.configurators
{

	import flash.display.Stage3D;

	import net.psykosoft.psykopaint2.app.controller.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.app.controller.gestures.GestureManager;
	import net.psykosoft.psykopaint2.app.util.DisplayContextManager;

	import org.swiftsuspenders.Injector;

	public class SingletonsConfig
	{
		public function SingletonsConfig( injector:Injector ) {
			injector.map( GestureManager ).asSingleton();
			injector.map( AccelerometerManager ).asSingleton();

			// TODO: shouldn't this be mapped in the core, it's only the core that uses the injected stage3d values
			injector.map( Stage3D ).toValue( DisplayContextManager.stage3dProxy.stage3D );
		}
	}
}
