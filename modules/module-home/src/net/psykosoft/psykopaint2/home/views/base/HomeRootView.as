package net.psykosoft.psykopaint2.home.views.base
{

	import net.psykosoft.psykopaint2.base.ui.base.RootViewBase;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.home.views.home.ContinuePaintingSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.NewPaintingSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.SettingsSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.WallpaperSubNavView;
	import net.psykosoft.psykopaint2.home.views.snapshot.HomeSnapShotView;

	public class HomeRootView extends RootViewBase
	{
		public function HomeRootView() {
			super();

			// Add main views.
			addRegisteredView( new HomeView(), this );
			addRegisteredView( new HomeSnapShotView(), this );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( StateType.HOME, HomeSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.HOME_ON_EMPTY_EASEL, NewPaintingSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.SETTINGS, SettingsSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.SETTINGS_WALLPAPER, WallpaperSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.HOME_ON_UNFINISHED_PAINTING, ContinuePaintingSubNavView );
		}
	}
}
