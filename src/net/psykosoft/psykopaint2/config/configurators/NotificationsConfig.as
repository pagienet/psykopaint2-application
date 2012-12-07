package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;

	import org.swiftsuspenders.Injector;

	public class NotificationsConfig
	{
		public function NotificationsConfig( injector:Injector ) {

			injector.map( NotifyStateChangedSignal ).asSingleton();

		}
	}
}
