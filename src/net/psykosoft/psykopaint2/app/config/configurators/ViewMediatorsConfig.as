package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.view.away3d.wall.WallView;
	import net.psykosoft.psykopaint2.app.view.away3d.wall.WallViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.base.StarlingRootSprite;
	import net.psykosoft.psykopaint2.app.view.starling.base.StarlingRootSpriteMediator;
	import net.psykosoft.psykopaint2.app.view.starling.painting.canvas.CanvasView;
	import net.psykosoft.psykopaint2.app.view.starling.painting.canvas.CanvasViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.painting.colorstyle.ColorStyleView;
	import net.psykosoft.psykopaint2.app.view.starling.painting.colorstyle.ColorStyleViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.painting.crop.CropView;
	import net.psykosoft.psykopaint2.app.view.starling.painting.crop.CropViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.CaptureImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.CaptureImageSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.ConfirmCaptureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.ConfirmCaptureSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.painting.crop.CropImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.painting.crop.CropImageSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.popups.CaptureImagePopUpView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.CaptureImagePopUpViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.NavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.NavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.process.EditStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.process.EditStyleSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.HomeScreenSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.HomeScreenSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.NewPaintingSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.NewPaintingSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.painting.canvas.SelectBrushSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.painting.canvas.SelectBrushSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.painting.colorstyle.ColorStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.painting.colorstyle.ColorStyleSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.SelectImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.SelectImageSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.process.SelectStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.process.SelectStyleSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.SelectTextureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.SelectTextureSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.settings.SelectWallpaperSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.settings.SelectWallpaperSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.settings.SettingsSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.settings.SettingsSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.popups.ConfirmCapturePopUpView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.ConfirmCapturePopUpViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.popups.MessagePopUpView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.MessagePopUpViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpManagerView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpManagerViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.selectimage.SelectThumbView;
	import net.psykosoft.psykopaint2.app.view.starling.selectimage.SelectThumbViewMediator;
	import net.psykosoft.psykopaint2.app.view.starling.splash.SplashView;
	import net.psykosoft.psykopaint2.app.view.starling.splash.SplashViewMediator;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

	public class ViewMediatorsConfig
	{
		public function ViewMediatorsConfig( mediatorMap:IMediatorMap ) {

			// ---------------------------------------------------------------------
			// 2d
			// ---------------------------------------------------------------------

			// General.
			mediatorMap.map( SplashView ).toMediator( SplashViewMediator );
			mediatorMap.map( StarlingRootSprite ).toMediator( StarlingRootSpriteMediator );

			// ---------------------------
			// Painting process views.
			// ---------------------------

			mediatorMap.map( SelectThumbView ).toMediator( SelectThumbViewMediator );
			mediatorMap.map( CanvasView ).toMediator( CanvasViewMediator );
			mediatorMap.map( CropView ).toMediator( CropViewMediator );
			mediatorMap.map( ColorStyleView ).toMediator( ColorStyleViewMediator );

			// ---------------------------
			// Pop up views.
			// ---------------------------

			mediatorMap.map( PopUpManagerView ).toMediator( PopUpManagerViewMediator );
			mediatorMap.map( MessagePopUpView ).toMediator( MessagePopUpViewMediator );
			mediatorMap.map( CaptureImagePopUpView ).toMediator( CaptureImagePopUpViewMediator );
			mediatorMap.map( ConfirmCapturePopUpView ).toMediator( ConfirmCapturePopUpViewMediator );

			// -----------------------
			// Sub-navigation views.
			// -----------------------

			mediatorMap.map( NavigationView ).toMediator( NavigationViewMediator );
			mediatorMap.map( SettingsSubNavigationView ).toMediator( SettingsSubNavigationViewMediator );
			mediatorMap.map( SelectWallpaperSubNavigationView ).toMediator( SelectWallpaperSubNavigationViewMediator );
			mediatorMap.map( HomeScreenSubNavigationView ).toMediator( HomeScreenSubNavigationViewMediator );
			// Painting process sub-navigation elements.
			mediatorMap.map( NewPaintingSubNavigationView ).toMediator( NewPaintingSubNavigationViewMediator );
			mediatorMap.map( SelectImageSubNavigationView ).toMediator( SelectImageSubNavigationViewMediator );
			mediatorMap.map( ColorStyleSubNavigationView ).toMediator( ColorStyleSubNavigationViewMediator );
			mediatorMap.map( SelectTextureSubNavigationView ).toMediator( SelectTextureSubNavigationViewMediator );
			mediatorMap.map( SelectBrushSubNavigationView ).toMediator( SelectBrushSubNavigationViewMediator );
			mediatorMap.map( SelectStyleSubNavigationView ).toMediator( SelectStyleSubNavigationViewMediator ); // This is where you paint.
			mediatorMap.map( EditStyleSubNavigationView ).toMediator( EditStyleSubNavigationViewMediator );
			mediatorMap.map( CaptureImageSubNavigationView ).toMediator( CaptureImageSubNavigationViewMediator );
			mediatorMap.map( ConfirmCaptureSubNavigationView ).toMediator( ConfirmCaptureSubNavigationViewMediator );
			mediatorMap.map( CropImageSubNavigationView ).toMediator( CropImageSubNavigationViewMediator );

			// ---------------------------------------------------------------------
			// 3d
			// ---------------------------------------------------------------------

			// General.
			mediatorMap.map( WallView ).toMediator( WallViewMediator );

		}
	}
}
