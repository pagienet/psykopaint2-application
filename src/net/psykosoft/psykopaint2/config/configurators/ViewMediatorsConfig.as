package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.view.away3d.wall.IWallView;
	import net.psykosoft.psykopaint2.view.away3d.wall.WallViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.NavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.NavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.homescreen.HomeScreenSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.homescreen.HomeScreenSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.popups.PopUpManagerView;
	import net.psykosoft.psykopaint2.view.starling.popups.PopUpManagerViewMediator;
	import net.psykosoft.psykopaint2.view.starling.popups.nofeature.FeatureNotImplementedPopUpView;
	import net.psykosoft.psykopaint2.view.starling.popups.nofeature.FeatureNotImplementedPopUpViewMediator;
	import net.psykosoft.psykopaint2.view.starling.splash.SplashView;
	import net.psykosoft.psykopaint2.view.starling.splash.SplashViewMediator;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

	public class ViewMediatorsConfig
	{
		public function ViewMediatorsConfig( mediatorMap:IMediatorMap ) {

			// Map 2d views.
			mediatorMap.map( SplashView ).toMediator( SplashViewMediator );

			// 2d Navigation views.
			mediatorMap.map( PopUpManagerView ).toMediator( PopUpManagerViewMediator );
			mediatorMap.map( NavigationView ).toMediator( NavigationViewMediator );
			mediatorMap.map( HomeScreenSubNavigationView ).toMediator( HomeScreenSubNavigationViewMediator );
			mediatorMap.map( FeatureNotImplementedPopUpView ).toMediator( FeatureNotImplementedPopUpViewMediator );

			// Map 3d views.
			mediatorMap.map( IWallView ).toMediator( WallViewMediator );

		}
	}
}
