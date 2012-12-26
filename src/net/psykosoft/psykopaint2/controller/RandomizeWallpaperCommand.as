package net.psykosoft.psykopaint2.controller
{

	import net.psykosoft.psykopaint2.signal.notifications.NotifyRandomWallpaperChangeSignal;

	public class RandomizeWallpaperCommand
	{
		[Inject]
		public var notifyRandomWallpaperChangeSignal:NotifyRandomWallpaperChangeSignal;

		public function execute():void {
			notifyRandomWallpaperChangeSignal.dispatch()
		}
	}
}
