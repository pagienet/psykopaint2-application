package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyRandomWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifySourceImagesUpdatedSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;

	import org.swiftsuspenders.Injector;

	public class NotificationsConfig
	{
		public function NotificationsConfig( injector:Injector ) {

			injector.map( NotifyStateChangedSignal ).asSingleton();
			injector.map( NotifyRandomWallpaperChangeSignal ).asSingleton();
			injector.map( NotifySourceImagesUpdatedSignal ).asSingleton();
			injector.map( NotifyPopUpMessageSignal ).asSingleton();
			injector.map( NotifyPopUpDisplaySignal ).asSingleton();
			injector.map( NotifyPopUpRemovalSignal ).asSingleton();

		}
	}
}
