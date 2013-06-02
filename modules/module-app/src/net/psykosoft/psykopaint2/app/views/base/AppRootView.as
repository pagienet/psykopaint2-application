package net.psykosoft.psykopaint2.app.views.base
{

	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.ui.base.RootViewBase;

	public class AppRootView extends RootViewBase
	{
		public function AppRootView() {
			super();

			// No views at the time, dispatching signal directly.
			setTimeout( function():void {
				allViewsReadySignal.dispatch();
			}, 25 );
		}
	}
}
