package net.psykosoft.psykopaint2.home
{

	import com.junkbyte.console.Cc;

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.home.config.HomeConfig;
	import net.psykosoft.psykopaint2.home.config.HomeConfig;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;

	import org.osflash.signals.Signal;
	import org.swiftsuspenders.Injector;

	public class HomeModule extends Sprite
	{
		private var _coreModule:CoreModule;

		public var moduleReadySignal:Signal;

		public function HomeModule() {
			super();
			trace( ">>>>> HomeModule starting..." );
			moduleReadySignal = new Signal();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initialize():void {
			// Request the core and wait for its initialization.
			// It is async because it loads assets, loads stage3d, etc...
			// TODO: if this module is used by a higher module, it should receive an already initialized core module.
			_coreModule = new CoreModule();
			_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
			addChild( _coreModule );
		}

		private function onCoreModuleReady( coreInjector:Injector ):void {
			Cc.log( this, "core module is ready, injector: " + coreInjector );

			// Initialize the home module.
			var config:HomeConfig = new HomeConfig( coreInjector );

			// Init display tree for this module.
			_coreModule.addChild( new HomeRootView() ); // Initialize display tree.

			// Trigger initial state...
			config.injector.getInstance( RequestStateChangeSignal ).dispatch( StateType.HOME );

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
