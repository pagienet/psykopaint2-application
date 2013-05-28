package net.psykosoft.psykopaint2.home.views.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;

	public class HomeRootView extends Sprite
	{
		public function HomeRootView() {
			super();

			var homeView:HomeView = new HomeView();

			addChild( homeView );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( StateType.STATE_HOME, HomeSubNavView );
		}
	}
}
