package net.psykosoft.psykopaint2.home.views.base
{

	import net.psykosoft.psykopaint2.base.ui.base.RootViewBase;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.newpainting.NewPaintingSubNavView;
	import net.psykosoft.psykopaint2.home.views.picksurface.PickSurfaceSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.SettingsSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.WallpaperSubNavView;

	public class HomeRootView extends RootViewBase
	{
		public function HomeRootView() {
			super();

			// Add main views.
			addRegisteredView( new HomeView(), this );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.HOME, HomeSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.HOME_ON_EASEL, NewPaintingSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.SETTINGS, SettingsSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.SETTINGS_WALLPAPER, WallpaperSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.HOME_PICK_SURFACE, PickSurfaceSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.PREPARE_FOR_PAINT_MODE, SubNavigationViewBase );

			name = "HomeRootView";
		}
	}
}
