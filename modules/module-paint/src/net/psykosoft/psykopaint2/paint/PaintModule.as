package net.psykosoft.psykopaint2.paint
{

	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.DrawingCore;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.paint.configuration.PaintConfig;
	import net.psykosoft.psykopaint2.paint.configuration.PaintSettings;
	import net.psykosoft.psykopaint2.paint.views.base.PaintRootView;

	public class PaintModule extends ModuleBase
	{
		private var _coreModule:CoreModule;

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

			// Init drawing core.
			new DrawingCore( _coreModule.injector );

			// Initialize robotlegs for this module.
			new PaintConfig( _coreModule.injector );

			// Init display tree for this module.
			var paintRootView:PaintRootView = new PaintRootView();
			_coreModule.injector.getInstance( RequestAddViewToMainLayerSignal ).dispatch( paintRootView );

			// Notify potential super modules.
			moduleReadySignal.dispatch( _coreModule.injector );
		}
	}
}
