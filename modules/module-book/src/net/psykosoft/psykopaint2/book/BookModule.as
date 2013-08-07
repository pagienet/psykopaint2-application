package net.psykosoft.psykopaint2.book
{

	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.book.config.BookConfig;
	import net.psykosoft.psykopaint2.book.config.BookSettings;
	import net.psykosoft.psykopaint2.book.views.base.BookRootView;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;

	public class BookModule extends ModuleBase
	{
		private var _coreModule:CoreModule;

		public function BookModule( core:CoreModule = null ) {
			super();
			_coreModule = core;
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "BookModule";
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
				BookSettings.isStandalone = true;
				_coreModule = new CoreModule();
				_coreModule.isStandalone = false;
				_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
				addChild( _coreModule );
			}
			else {
				BookSettings.isStandalone = false;
				onCoreModuleReady();
			}
		}

		private function onCoreModuleReady():void {

			// Initialize the home module.
			new BookConfig( _coreModule.injector );

			// Init display tree for this module.
			var bookRootView:BookRootView = new BookRootView();
			_coreModule.injector.getInstance( RequestAddViewToMainLayerSignal ).dispatch( bookRootView );

			// Notify potential super modules.
			moduleReadySignal.dispatch();
		}
	}
}
