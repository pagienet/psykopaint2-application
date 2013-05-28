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
	import net.psykosoft.psykopaint2.home.HomeModule;
	import net.psykosoft.psykopaint2.paint.PaintModule;

	import org.swiftsuspenders.Injector;

	// TODO: fix rendering conflict between the paint and the home module...

	public class AppModule extends ModuleBase
	{
		private var _coreModule:CoreModule;

		public function AppModule() {
			super();
			trace( ">>>>> AppModule starting..." );
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
			_coreModule.isStandalone = false;
			_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
			addChild( _coreModule );
		}
		private function onCoreModuleReady( coreInjector:Injector ):void {
			Cc.log( this, "core module is ready, injector: " + coreInjector );
			// TODO: remove time out calls, they are used because otherwise, usage of the paint and home modules simultaneously causes the core's injected stage3d.context3d to become null
			setTimeout( createHomeModule, 250 );
//			createPaintModule();
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
			Cc.log( this, "home module is ready" );
			setTimeout( createPaintModule, 250 );
//			finishInitialization();
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
		    Cc.log( this, "paint module is ready" );
			finishInitialization();
		}

		private function finishInitialization():void {
			// Initialize the app module.
			new AppConfig( _coreModule.injector );

			// Init display tree for this module.
			_coreModule.addChild( new AppRootView() );
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
