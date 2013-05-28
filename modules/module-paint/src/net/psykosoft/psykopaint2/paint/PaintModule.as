package net.psykosoft.psykopaint2.paint
{

	import com.junkbyte.console.Cc;

	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.ModuleBase;
	import net.psykosoft.psykopaint2.core.drawing.DrawingCore;
	import net.psykosoft.psykopaint2.paint.config.PaintConfig;
	import net.psykosoft.psykopaint2.paint.signals.requests.RequestDrawingCoreStartupSignal;
	import net.psykosoft.psykopaint2.paint.views.base.PaintRootView;

	import org.swiftsuspenders.Injector;

	public class PaintModule extends ModuleBase
	{
		private var _coreModule:CoreModule;

		public function PaintModule( core:CoreModule = null ) {
			super();
			trace( ">>>>> PaintModule starting..." );
			_coreModule = core;
			if( !_coreModule ) {
				addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			}
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		public function initialize():void {
			trace( this, "initializing..." );
			// Init core module.
			if( !_coreModule ) {
				_coreModule = new CoreModule();
				_coreModule.isStandalone = false;
				_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
				addChild( _coreModule );
			}
			else {
				onCoreModuleReady( _coreModule.injector );
			}
		}

		private function onCoreModuleReady( coreInjector:Injector ):void {
			Cc.log( this, "core module is ready, injector: " + coreInjector );

			// Init drawing core.
			new DrawingCore( coreInjector );

			// Initialize the paint module.
			var config:PaintConfig = new PaintConfig( coreInjector );

			// Init display tree for this module.
			_coreModule.addModuleDisplay( new PaintRootView() ); // Initialize display tree.

			// Init drawing core.
			config.injector.getInstance( RequestDrawingCoreStartupSignal ).dispatch(); // Ignite drawing core, causes first "real" application states...

			// Notify potential super modules.
			moduleReadySignal.dispatch( coreInjector );
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}
	}
}
