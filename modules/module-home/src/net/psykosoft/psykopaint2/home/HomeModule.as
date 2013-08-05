package net.psykosoft.psykopaint2.home
{

	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.home.config.HomeConfig;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;

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

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}

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

			// Initialize robotlegs for this module.
			new HomeConfig( _coreModule.injector );

			// Init display tree for this module.
			var homeRootView:HomeRootView = new HomeRootView();
			_coreModule.injector.getInstance( RequestAddViewToMainLayerSignal ).dispatch( homeRootView );

			// Notify potential super modules.
			moduleReadySignal.dispatch();
		}
	}
}
