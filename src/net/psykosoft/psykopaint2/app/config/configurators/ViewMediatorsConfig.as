package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.view.away3d.wall.WallView;
	import net.psykosoft.psykopaint2.app.view.away3d.wall.WallViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.base.StarlingRootSprite;
	import net.psykosoft.psykopaint2.app.view.starling.base.StarlingRootSpriteMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.CaptureImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.CaptureImageSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.ConfirmCaptureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.ConfirmCaptureSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.popups.CaptureImagePopUpView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.CaptureImagePopUpViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.NavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.NavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.EditStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.EditStyleSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.HomeScreenSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.HomeScreenSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.NewPaintingSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.NewPaintingSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectBrushSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectBrushSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectColorsSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectColorsSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectImageSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectStyleSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectTextureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectTextureSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectWallpaperSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectWallpaperSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SettingsSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SettingsSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.popups.ConfirmCapturePopUpView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.ConfirmCapturePopUpViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.popups.MessagePopUpView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.MessagePopUpViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpManagerView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpManagerViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.selectimage.SelectImageView;
	import net.psykosoft.psykopaint2.app.view.starling.selectimage.SelectImageViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.splash.SplashView;
	import net.psykosoft.psykopaint2.app.view.starling.splash.SplashViewMediator;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

	public class ViewMediatorsConfig
	{
		public function ViewMediatorsConfig( mediatorMap:IMediatorMap ) {

			// -----------------------
			// 2d
			// -----------------------

			// General.
			mediatorMap.map( SplashView ).toMediator( SplashViewMediator );
			mediatorMap.map( StarlingRootSprite ).toMediator( StarlingRootSpriteMediator );

			// Painting process.
			mediatorMap.map( SelectImageView ).toMediator( SelectImageViewMediator );

			// 2d Pop up views.
			mediatorMap.map( PopUpManagerView ).toMediator( PopUpManagerViewMediator );
			mediatorMap.map( MessagePopUpView ).toMediator( MessagePopUpViewMediator );
			mediatorMap.map( CaptureImagePopUpView ).toMediator( CaptureImagePopUpViewMediator );
			mediatorMap.map( ConfirmCapturePopUpView ).toMediator( ConfirmCapturePopUpViewMediator );

			// 2d Navigation views.
			mediatorMap.map( NavigationView ).toMediator( NavigationViewMediator );
			mediatorMap.map( SettingsSubNavigationView ).toMediator( SettingsSubNavigationViewMediator );
			mediatorMap.map( SelectWallpaperSubNavigationView ).toMediator( SelectWallpaperSubNavigationViewMediator );
			mediatorMap.map( HomeScreenSubNavigationView ).toMediator( HomeScreenSubNavigationViewMediator );
			// Painting process sub-navigation elements.
			mediatorMap.map( NewPaintingSubNavigationView ).toMediator( NewPaintingSubNavigationViewMediator );
			mediatorMap.map( SelectImageSubNavigationView ).toMediator( SelectImageSubNavigationViewMediator );
			mediatorMap.map( SelectColorsSubNavigationView ).toMediator( SelectColorsSubNavigationViewMediator );
			mediatorMap.map( SelectTextureSubNavigationView ).toMediator( SelectTextureSubNavigationViewMediator );
			mediatorMap.map( SelectBrushSubNavigationView ).toMediator( SelectBrushSubNavigationViewMediator );
			mediatorMap.map( SelectStyleSubNavigationView ).toMediator( SelectStyleSubNavigationViewMediator ); // This is where you paint.
			mediatorMap.map( EditStyleSubNavigationView ).toMediator( EditStyleSubNavigationViewMediator );
			mediatorMap.map( CaptureImageSubNavigationView ).toMediator( CaptureImageSubNavigationViewMediator );
			mediatorMap.map( ConfirmCaptureSubNavigationView ).toMediator( ConfirmCaptureSubNavigationViewMediator );

			// -----------------------
			// 3d
			// -----------------------

			// General.
			mediatorMap.map( WallView ).toMediator( WallViewMediator );

		}
	}
}
