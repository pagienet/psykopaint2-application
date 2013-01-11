package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.view.away3d.wall.IWallView;
	import net.psykosoft.psykopaint2.view.away3d.wall.WallViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.NavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.NavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.homescreen.HomeScreenSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.homescreen.HomeScreenSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.selectimage.SelectImageSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.selectimage.SelectImageSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.popups.PopUpManagerView;
	import net.psykosoft.psykopaint2.view.starling.popups.PopUpManagerViewMediator;
	import net.psykosoft.psykopaint2.view.starling.popups.nofeature.FeatureNotImplementedPopUpView;
	import net.psykosoft.psykopaint2.view.starling.popups.nofeature.FeatureNotImplementedPopUpViewMediator;
	import net.psykosoft.psykopaint2.view.starling.selectimage.SelectImageView;
	import net.psykosoft.psykopaint2.view.starling.selectimage.SelectImageViewMediator;
	import net.psykosoft.psykopaint2.view.starling.splash.SplashView;
	import net.psykosoft.psykopaint2.view.starling.splash.SplashViewMediator;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

	public class ViewMediatorsConfig
	{
		public function ViewMediatorsConfig( mediatorMap:IMediatorMap ) {

			// -----------------------
			// 2d
			// -----------------------

			mediatorMap.map( SplashView ).toMediator( SplashViewMediator );
			mediatorMap.map( SelectImageView ).toMediator( SelectImageViewMediator );

			// 2d Pop up views.
			mediatorMap.map( PopUpManagerView ).toMediator( PopUpManagerViewMediator );
			mediatorMap.map( FeatureNotImplementedPopUpView ).toMediator( FeatureNotImplementedPopUpViewMediator );

			// 2d Navigation views.
			mediatorMap.map( NavigationView ).toMediator( NavigationViewMediator );
			mediatorMap.map( HomeScreenSubNavigationView ).toMediator( HomeScreenSubNavigationViewMediator );
			mediatorMap.map( SelectImageSubNavigationView ).toMediator( SelectImageSubNavigationViewMediator );

			// -----------------------
			// 3d
			// -----------------------

			mediatorMap.map( IWallView ).toMediator( WallViewMediator );

		}
	}
}
