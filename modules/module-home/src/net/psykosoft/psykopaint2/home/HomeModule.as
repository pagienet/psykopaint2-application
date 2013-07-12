package net.psykosoft.psykopaint2.home
{

	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.home.config.HomeConfig;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;

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
				HomeSettings.isStandalone = true;
				_coreModule = new CoreModule();
				_coreModule.isStandalone = false;
				_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
				addChild( _coreModule );
			}
			else {
				HomeSettings.isStandalone = false;
				onCoreModuleReady();
			}
		}

		private function onCoreModuleReady():void {
			trace( this, "core module is ready, injector: " + _coreModule.injector );

			// Initialize the home module.
			_homeConfig = new HomeConfig( _coreModule.injector );

			// Init display tree for this module.
			var homeRootView:HomeRootView = new HomeRootView();
			homeRootView.allViewsReadySignal.addOnce( onViewsReady );
			_coreModule.addModuleDisplay( homeRootView );
		}

		private function onViewsReady():void {

			trace( this, "HomeModule views are ready." );

			if( isStandalone ) {
				// Remove splash screen.
				_coreModule.coreRootView.removeSplashScreen();
				// Show Navigation.
			var showNavigationSignal:RequestNavigationToggleSignal = _coreModule.injector.getInstance( RequestNavigationToggleSignal );
			showNavigationSignal.dispatch( 1, 0.5 );
				// Trigger initial state...
				_homeConfig.injector.getInstance( RequestStateChangeSignal ).dispatch( StateType.HOME );
				_coreModule.startEnterFrame();
			}

			// Notify potential super modules.
			moduleReadySignal.dispatch( _coreModule.injector );
		}
	}
}
