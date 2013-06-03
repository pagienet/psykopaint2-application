package net.psykosoft.psykopaint2.home.views.base
{

	import net.psykosoft.psykopaint2.base.ui.base.RootViewBase;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.NewPaintingSubNavView;

	public class HomeRootView extends RootViewBase
	{
		public function HomeRootView() {
			super();

			// Add main views.
			addRegisteredView( new HomeView(), this );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( StateType.STATE_HOME, HomeSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.STATE_HOME_ON_EASEL, NewPaintingSubNavView );
		}
	}
}
