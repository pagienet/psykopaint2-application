package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.signal.notifications.NotifyGlobalAccelerometerSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyNavigationToggleSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifySourceImagesUpdatedSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyWallpaperImagesUpdatedSignal;

	import org.swiftsuspenders.Injector;

	public class NotificationsConfig
	{
		public function NotificationsConfig( injector:Injector ) {

			injector.map( NotifyStateChangedSignal ).asSingleton();
			injector.map( NotifySourceImagesUpdatedSignal ).asSingleton();
			injector.map( NotifyWallpaperImagesUpdatedSignal ).asSingleton();
			injector.map( NotifyPopUpMessageSignal ).asSingleton();
			injector.map( NotifyPopUpDisplaySignal ).asSingleton();
			injector.map( NotifyPopUpRemovalSignal ).asSingleton();
			injector.map( NotifyWallpaperChangeSignal ).asSingleton();
			injector.map( NotifyGlobalGestureSignal ).asSingleton();
			injector.map( NotifyNavigationToggleSignal ).asSingleton();
			injector.map( NotifyGlobalAccelerometerSignal ).asSingleton();

		}
	}
}
