package net.psykosoft.psykopaint2.home.views.home
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class HomeSubNavView extends SubNavigationViewBase
	{
		public function HomeSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Home" );
			navigation.layout();
		}
	}
}
