package net.psykosoft.psykopaint2.paint
{

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;

	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;

	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.DrawingCore;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.paint.config.PaintConfig;
	import net.psykosoft.psykopaint2.paint.config.PaintSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.paint.signals.RequestDrawingCoreStartupSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSavedDataRetrievalSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSurfaceImageSetSignal;
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
			// Load default surface.
			_loader = new BinaryLoader();
			var size : int = stage.stageWidth;
			_loader.loadAsset( "/paint-packaged/surfaces/canvas_normal_specular_" + size + ".surf", onDefaultSurfaceLoaded );
		}

		private function onDefaultSurfaceLoaded( byteArray:ByteArray ):void {

			_loader.dispose();
			_loader = null;

			// Set default surface.
			_paintConfig.injector.getInstance( RequestSurfaceImageSetSignal ).dispatch( byteArray );

			if( isStandalone ) {

				// Init drawing core.
				_paintConfig.injector.getInstance( RequestDrawingCoreStartupSignal ).dispatch(); // Start drawing core, causes first "real" application states...

				// Show navigation.
				var showNavigationSignal:RequestNavigationToggleSignal = _coreModule.injector.getInstance( RequestNavigationToggleSignal );
				showNavigationSignal.dispatch( 1 );

				// Remove splash screen.
				_coreModule.coreRootView.removeSplashScreen();
				_coreModule.startEnterFrame();
			}

			// Start loading painting data.
			registerClassAlias( "PaintingVO", PaintingVO );
			_paintConfig.injector.getInstance( RequestPaintingSavedDataRetrievalSignal ).dispatch();

			// Notify potential super modules.
			moduleReadySignal.dispatch( _coreModule.injector );
		}
	}
}
