package net.psykosoft.psykopaint2.app
{

	import com.junkbyte.console.Cc;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.app.config.AppConfig;
	import net.psykosoft.psykopaint2.app.views.base.AppRootView;
	import net.psykosoft.psykopaint2.core.ModuleBase;

	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
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
		private function onCoreModuleReady( coreInjector:Injector ):void {
			trace( this, "core module is ready, injector: " + coreInjector );

			// TODO: remove time out calls, they are used because otherwise, usage of the paint and home modules simultaneously causes the core's injected stage3d.context3d to become null
			setTimeout( createPaintModule, 250 );
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
			setTimeout( createHomeModule, 250 );
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

			// Launch core updates.
			_coreModule.updateActive = true;
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
