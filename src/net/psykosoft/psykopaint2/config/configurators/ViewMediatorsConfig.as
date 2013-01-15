package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.view.away3d.wall.IWallView;
	import net.psykosoft.psykopaint2.view.away3d.wall.WallViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.NavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.NavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.homescreen.HomeScreenSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.homescreen.HomeScreenSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.editstyle.EditStyleSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.editstyle.EditStyleSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.newpainting.NewPaintingSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.newpainting.NewPaintingSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectbrush.SelectBrushSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectbrush.SelectBrushSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectcolors.SelectColorsSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectcolors.SelectColorsSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectimage.SelectImageSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectimage.SelectImageSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectstyle.SelectStyleSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectstyle.SelectStyleSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selecttexture.SelectTextureSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selecttexture.SelectTextureSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.view.starling.popups.PopUpManagerView;
	import net.psykosoft.psykopaint2.view.starling.popups.PopUpManagerViewMediator;
	import net.psykosoft.psykopaint2.view.starling.popups.noplatform.FeatureNotInPlatformPopUpView;
	import net.psykosoft.psykopaint2.view.starling.popups.noplatform.FeatureNotInPlatformPopUpViewMediator;
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

			// General.
			mediatorMap.map( SplashView ).toMediator( SplashViewMediator );

			// Painting process.
			mediatorMap.map( SelectImageView ).toMediator( SelectImageViewMediator );

			// 2d Pop up views.
			mediatorMap.map( PopUpManagerView ).toMediator( PopUpManagerViewMediator );
			mediatorMap.map( FeatureNotImplementedPopUpView ).toMediator( FeatureNotImplementedPopUpViewMediator );
			mediatorMap.map( FeatureNotInPlatformPopUpView ).toMediator( FeatureNotInPlatformPopUpViewMediator );

			// 2d Navigation views.
			mediatorMap.map( NavigationView ).toMediator( NavigationViewMediator );
			mediatorMap.map( HomeScreenSubNavigationView ).toMediator( HomeScreenSubNavigationViewMediator );
			// Painting process sub-navigation elements.
			mediatorMap.map( NewPaintingSubNavigationView ).toMediator( NewPaintingSubNavigationViewMediator );
			mediatorMap.map( SelectImageSubNavigationView ).toMediator( SelectImageSubNavigationViewMediator );
			mediatorMap.map( SelectColorsSubNavigationView ).toMediator( SelectColorsSubNavigationViewMediator );
			mediatorMap.map( SelectTextureSubNavigationView ).toMediator( SelectTextureSubNavigationViewMediator );
			mediatorMap.map( SelectBrushSubNavigationView ).toMediator( SelectBrushSubNavigationViewMediator );
			mediatorMap.map( SelectStyleSubNavigationView ).toMediator( SelectStyleSubNavigationViewMediator ); // This is where you paint.
			mediatorMap.map( EditStyleSubNavigationView ).toMediator( EditStyleSubNavigationViewMediator );

			// -----------------------
			// 3d
			// -----------------------

			// General.
			mediatorMap.map( IWallView ).toMediator( WallViewMediator );

		}
	}
}
