package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.view.home.HomeView;
	import net.psykosoft.psykopaint2.app.view.home.HomeViewMediator;
	import net.psykosoft.psykopaint2.app.view.base.StarlingRootSprite;
	import net.psykosoft.psykopaint2.app.view.base.StarlingRootSpriteMediator;
	import net.psykosoft.psykopaint2.app.view.painting.canvas.CanvasView;
	import net.psykosoft.psykopaint2.app.view.painting.canvas.CanvasViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.colorstyle.ColorStyleView;
	import net.psykosoft.psykopaint2.app.view.painting.colorstyle.ColorStyleViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.crop.CropView;
	import net.psykosoft.psykopaint2.app.view.painting.crop.CropViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.captureimage.CaptureImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.captureimage.CaptureImageSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.captureimage.ConfirmCaptureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.captureimage.ConfirmCaptureSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.crop.CropImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.crop.CropImageSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.stateproxy.StateProxyView;
	import net.psykosoft.psykopaint2.app.view.painting.stateproxy.StateProxyViewMediator;
	import net.psykosoft.psykopaint2.app.view.popups.CaptureImagePopUpView;
	import net.psykosoft.psykopaint2.app.view.popups.CaptureImagePopUpViewMediator;
	import net.psykosoft.psykopaint2.app.view.navigation.NavigationView;
	import net.psykosoft.psykopaint2.app.view.navigation.NavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.editstyle.EditStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.editstyle.EditStyleSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.home.HomeScreenSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.home.HomeScreenSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.newpainting.NewPaintingSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.newpainting.NewPaintingSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.canvas.SelectBrushSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.canvas.SelectBrushSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.colorstyle.ColorStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.colorstyle.ColorStyleSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.selectimage.SelectImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.selectimage.SelectImageSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.selectstyle.SelectStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.selectstyle.SelectStyleSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.painting.selecttexture.SelectTextureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.selecttexture.SelectTextureSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.settings.SelectWallpaperSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.settings.SelectWallpaperSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.settings.SettingsSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.settings.SettingsSubNavigationViewMediator;
	import net.psykosoft.psykopaint2.app.view.popups.ConfirmCapturePopUpView;
	import net.psykosoft.psykopaint2.app.view.popups.ConfirmCapturePopUpViewMediator;
	import net.psykosoft.psykopaint2.app.view.popups.MessagePopUpView;
	import net.psykosoft.psykopaint2.app.view.popups.MessagePopUpViewMediator;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpManagerView;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpManagerViewMediator;
	import net.psykosoft.psykopaint2.app.view.selectimage.SelectThumbView;
	import net.psykosoft.psykopaint2.app.view.selectimage.SelectThumbViewMediator;
	import net.psykosoft.psykopaint2.app.view.splash.SplashView;
	import net.psykosoft.psykopaint2.app.view.splash.SplashViewMediator;

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

			mediatorMap.map( StateProxyView ).toMediator( StateProxyViewMediator );
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
			mediatorMap.map( HomeView ).toMediator( HomeViewMediator );

		}
	}
}
