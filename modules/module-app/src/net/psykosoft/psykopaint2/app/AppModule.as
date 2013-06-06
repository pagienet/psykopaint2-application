package net.psykosoft.psykopaint2.app
{

	import flash.events.Event;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.app.config.AppConfig;
	import net.psykosoft.psykopaint2.app.views.base.AppRootView;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.base.utils.ModuleBase;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.home.HomeModule;
	import net.psykosoft.psykopaint2.paint.PaintModule;

	import org.swiftsuspenders.Injector;

	// TODO: fix rendering conflict between the paint and the home module...

	public class AppModule extends ModuleBase
	{
		private var _coreModule:CoreModule;

		public function AppModule() {
			super();
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "AppModule";
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
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

		private function initialize():void {
			createCoreModule();
		}

		// Core module.
		private function createCoreModule():void {
			trace( this, "creating core module..." );
			_coreModule = new CoreModule();
			_coreModule.updateActive = false;
			_coreModule.isStandalone = false;
			_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
			addChild( _coreModule );
		}
		private function onCoreModuleReady():void {
			trace( this, "core module is ready, injector: " + _coreModule.injector );

			// TODO: remove time out calls, they are used because otherwise, usage of the paint and home modules simultaneously causes the core's injected stage3d.context3d to become null
//			setTimeout( createPaintModule, 250 );
			createPaintModule();
		}

		// Paint module.
		private function createPaintModule():void {
//			var rlStage:Stage = _coreModule.injector.getInstance( Stage );
//			var rlStage3d:Stage3D = _coreModule.injector.getInstance( Stage3D );
			trace( this, "creating paint module..." );
			var paintModule:PaintModule = new PaintModule( _coreModule );
			paintModule.isStandalone = false;
			paintModule.moduleReadySignal.addOnce( onPaintModuleReady );
			paintModule.initialize();
		}
		private function onPaintModuleReady( coreInjector:Injector ):void {
		    trace( this, "paint module is ready" );
//			setTimeout( createHomeModule, 250 );
			createHomeModule();
		}

		// Home module.
		private function createHomeModule():void {
			trace( this, "creating home module..." );
			var homeModule:HomeModule = new HomeModule( _coreModule );
			homeModule.isStandalone = false;
			homeModule.moduleReadySignal.addOnce( onHomeModuleReady );
			homeModule.initialize();
		}
		private function onHomeModuleReady( coreInjector:Injector ):void {
			trace( this, "home module is ready" );

			// Initialize the app module.
			new AppConfig( _coreModule.injector );

			// Init display tree for this module.
			var appRootView:AppRootView = new AppRootView();
			appRootView.allViewsReadySignal.addOnce( onViewsReady );
			_coreModule.addModuleDisplay( appRootView );
		}

		private function onViewsReady():void {

			// Trigger initial state...
			_coreModule.injector.getInstance( RequestStateChangeSignal ).dispatch( StateType.STATE_HOME );

			// Listen for splash out.
			_coreModule.splashScreenRemovedSignal.addOnce( onSplashOut );

			// Launch core updates.
			_coreModule.updateActive = true;
		}

		private function onSplashOut():void {

			// Show navigation.
			setTimeout( function ():void { // Wait a bit while the view is zooming out...
				var showNavigationSignal:RequestNavigationToggleSignal = _coreModule.injector.getInstance( RequestNavigationToggleSignal );
				showNavigationSignal.dispatch();
			}, 2000 );
		}
	}
}
