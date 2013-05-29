package net.psykosoft.psykopaint2.paint
{

	import com.junkbyte.console.Cc;

	import flash.events.Event;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.ModuleBase;
	import net.psykosoft.psykopaint2.core.drawing.DrawingCore;
	import net.psykosoft.psykopaint2.paint.config.PaintConfig;
	import net.psykosoft.psykopaint2.paint.config.PaintSettings;
	import net.psykosoft.psykopaint2.paint.signals.requests.RequestDrawingCoreStartupSignal;
	import net.psykosoft.psykopaint2.paint.views.base.PaintRootView;

	import org.swiftsuspenders.Injector;

	public class PaintModule extends ModuleBase
	{
		private var _coreModule:CoreModule;
		private var _paintConfig:PaintConfig;

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
				PaintSettings.isStandalone = true;
				_coreModule = new CoreModule();
				_coreModule.isStandalone = false;
				_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
				addChild( _coreModule );
			}
			else {
				PaintSettings.isStandalone = false;
				onCoreModuleReady( _coreModule.injector );
			}
		}

		private function onCoreModuleReady( coreInjector:Injector ):void {
			Cc.log( this, "core module is ready, injector: " + coreInjector );

			// Init drawing core.
			new DrawingCore( coreInjector );

			// Initialize the paint module.
			_paintConfig = new PaintConfig( coreInjector );

			// Init display tree for this module.
			_coreModule.addModuleDisplay( new PaintRootView() ); // Initialize display tree.

			// Init drawing core.
			startCore();
//			setTimeout( startModule, 2000 ); // TODO: remove time out, currently necessary because some views are not ready yet ( on stage )

			// Notify potential super modules.
			moduleReadySignal.dispatch( coreInjector );
		}

		private function startCore():void {
			_paintConfig.injector.getInstance( RequestDrawingCoreStartupSignal ).dispatch(); // Ignite drawing core, causes first "real" application states...
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
