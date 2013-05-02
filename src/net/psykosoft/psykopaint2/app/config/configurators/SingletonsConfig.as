package net.psykosoft.psykopaint2.app.config.configurators
{

	import flash.display.Stage3D;

	import net.psykosoft.psykopaint2.core.managers.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.app.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;

	import org.swiftsuspenders.Injector;

	public class SingletonsConfig
	{
		public function SingletonsConfig( injector:Injector ) {

			injector.map( GestureManager ).asSingleton();

			// TODO: shouldn't this be mapped in the core, it's only the core that uses the injected stage3d values
			injector.map( Stage3D ).toValue( DisplayContextManager.stage3dProxy.stage3D );
		}
	}
}
