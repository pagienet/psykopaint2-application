package net.psykosoft.psykopaint2.home
{

	import com.junkbyte.console.Cc;

	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.ModuleBase;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.home.config.HomeConfig;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;

	import org.swiftsuspenders.Injector;

	public class HomeModule extends ModuleBase
	{
		private var _coreModule:CoreModule;

		public function HomeModule( core:CoreModule = null ) {
			super();
			_coreModule = core;
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "HomeModule";
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

			// Initialize the home module.
			var config:HomeConfig = new HomeConfig( coreInjector );

			// Init display tree for this module.
			_coreModule.addModuleDisplay( new HomeRootView() );

			// Notify potential super modules.
			moduleReadySignal.dispatch( coreInjector );

			// Start local enterframe is standalone.
			if( isStandalone ) {
				trace( this, " >>> starting as standalone." );
				// Trigger initial state...
				config.injector.getInstance( RequestStateChangeSignal ).dispatch( StateType.STATE_HOME );
			}
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
