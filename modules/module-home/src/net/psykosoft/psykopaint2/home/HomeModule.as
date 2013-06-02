package net.psykosoft.psykopaint2.home
{

	import flash.events.Event;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.ModuleBase;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.home.config.HomeConfig;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;

	import org.swiftsuspenders.Injector;

	public class HomeModule extends ModuleBase
	{
		private var _coreModule:CoreModule;
		private var _homeConfig:HomeConfig;

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
				HomeSettings.isStandalone = true;
				_coreModule = new CoreModule();
				_coreModule.isStandalone = false;
				_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
				addChild( _coreModule );
			}
			else {
				HomeSettings.isStandalone = false;
				onCoreModuleReady( _coreModule.injector );
			}
		}

		private function onCoreModuleReady( coreInjector:Injector ):void {
			trace( this, "core module is ready, injector: " + coreInjector );

			// Initialize the home module.
			_homeConfig = new HomeConfig( coreInjector );

			// Init display tree for this module.
			var homeRootView:HomeRootView = new HomeRootView();
			homeRootView.allViewsReadySignal.addOnce( onViewsReady );
			_coreModule.addModuleDisplay( homeRootView );
		}

		private function onViewsReady():void {

			// First state.
			if( isStandalone ) {
				trace( this, " >>> starting as standalone." );
				// Trigger initial state...
				_homeConfig.injector.getInstance( RequestStateChangeSignal ).dispatch( StateType.STATE_HOME );
			}

			// Notify potential super modules.
			moduleReadySignal.dispatch( _coreModule.injector );
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
