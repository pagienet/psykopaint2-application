package net.psykosoft.psykopaint2.paint
{

	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.base.utils.ModuleBase;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.DrawingCore;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.paint.config.PaintConfig;
	import net.psykosoft.psykopaint2.paint.config.PaintSettings;
	import net.psykosoft.psykopaint2.paint.signals.RequestDrawingCoreStartupSignal;
	import net.psykosoft.psykopaint2.paint.views.base.PaintRootView;

	public class PaintModule extends ModuleBase
	{
		private var _coreModule:CoreModule;
		private var _paintConfig:PaintConfig;

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

			// Listen for splash out.
			_coreModule.coreRootView.splashScreenRemovedSignal.addOnce( onSplashOut );

			// Init drawing core.
			_paintConfig.injector.getInstance( RequestDrawingCoreStartupSignal ).dispatch(); // Ignite drawing core, causes first "real" application states...

			// Notify potential super modules.
			moduleReadySignal.dispatch( _coreModule.injector );
		}

		private function onSplashOut():void {
			if( isStandalone ) {
				// Show navigation.
				var showNavigationSignal:RequestNavigationToggleSignal = _coreModule.injector.getInstance( RequestNavigationToggleSignal );
				showNavigationSignal.dispatch( 1 );
			}
		}
	}
}
