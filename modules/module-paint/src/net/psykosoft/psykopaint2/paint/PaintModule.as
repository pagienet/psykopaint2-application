package net.psykosoft.psykopaint2.paint
{

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;
	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.DrawingCore;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSetCanvasSurfaceSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.paint.configuration.PaintConfig;
	import net.psykosoft.psykopaint2.paint.configuration.PaintSettings;
	import net.psykosoft.psykopaint2.paint.views.base.PaintRootView;

	public class PaintModule extends ModuleBase
	{
		private var _coreModule:CoreModule;
		private var _paintConfig:PaintConfig;
		private var _loader:BinaryLoader;

		public function PaintModule( core:CoreModule = null ) {
			super();
			_coreModule = core;
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "PaintModule";
			if( !_coreModule ) {
				addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			}
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		public function initialize():void {
			trace( this, "initializing..." );
			// Init core module.
			if( !_coreModule ) {
				PaintSettings.isStandalone = true;
				_coreModule = new CoreModule();
				_coreModule.isStandalone = false;
				_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
				addChild( _coreModule );
			}
			else {
				PaintSettings.isStandalone = false;
				onCoreModuleReady();
			}
		}

		private function onCoreModuleReady():void {
			trace( this, "core module is ready, injector: " + _coreModule.injector );

			// Init drawing core.
			new DrawingCore( _coreModule.injector );

			// Initialize the paint module.
			_paintConfig = new PaintConfig( _coreModule.injector );

			// Init display tree for this module.
			var rootView:PaintRootView = new PaintRootView();
			rootView.allViewsReadySignal.addOnce( onViewsReady );
			_coreModule.addModuleDisplay( rootView );
		}

		private function onViewsReady():void {
			// Notify potential super modules.
			moduleReadySignal.dispatch( _coreModule.injector );

			if( isStandalone ) {
				loadDefaultSurface();
			}
		}

		private function loadDefaultSurface():void {
			_loader = new BinaryLoader();
			var size:int = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2048 : 1024;
			_loader.loadAsset( "/core-packaged/images/surfaces/canvas_normal_specular_0_" + size + ".surf", onDefaultSurfaceLoaded );
		}

		private function onDefaultSurfaceLoaded( byteArray:ByteArray ):void {
			_loader.dispose();
			_loader = null;

			// Set default surface.
			_paintConfig.injector.getInstance( RequestSetCanvasSurfaceSignal ).dispatch( byteArray, null );

			loadDefaultSourceImage();
		}

		private function loadDefaultSourceImage():void {
			// TODO: load a sample image
			onDefaultSourceImageLoaded();
		}

		private function onDefaultSourceImageLoaded():void {

			// Set source image.
			var perlinBmd:BitmapData = new BitmapData( 1024 * CoreSettings.GLOBAL_SCALING, 768 * CoreSettings.GLOBAL_SCALING, false, 0 );
			perlinBmd.perlinNoise( 50, 50, 8, uint( 1000 * Math.random() ), false, true, 7, true );

			// Causes drawing core module activation and hence an application state change via UpdateAppStateFromActivatedDrawingCoreModuleCommand.
			_coreModule.injector.getInstance( NotifyCropCompleteSignal ).dispatch( perlinBmd ); // Launches app in paint mode.

			// Show navigation.
			_coreModule.injector.getInstance( RequestNavigationToggleSignal ).dispatch( 1, 0.5 );

			// Remove splash screen.
			_coreModule.coreRootView.removeSplashScreen();
			_coreModule.startEnterFrame();
		}
	}
}
