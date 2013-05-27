package net.psykosoft.psykopaint2.app
{

	import com.junkbyte.console.Cc;

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.app.config.AppConfig;
	import net.psykosoft.psykopaint2.app.views.base.AppRootView;
	import net.psykosoft.psykopaint2.core.ModuleBase;

	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.home.HomeModule;
	import net.psykosoft.psykopaint2.paint.PaintModule;

	import org.swiftsuspenders.Injector;

	public class ModuleApp extends ModuleBase
	{
		private var _coreModule:CoreModule;

		public function ModuleApp() {
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
			_coreModule.moduleReadySignal.addOnce( onCoreModuleReady );
			addChild( _coreModule );
		}
		private function onCoreModuleReady( coreInjector:Injector ):void {
			Cc.log( this, "core module is ready, injector: " + coreInjector );
			createHomeModule();
		}

		// Home module.
		private function createHomeModule():void {
			trace( this, "creating home module..." );
			var homeModule:HomeModule = new HomeModule( _coreModule );
			homeModule.moduleReadySignal.addOnce( onHomeModuleReady );
			homeModule.initialize();
		}
		private function onHomeModuleReady( coreInjector:Injector ):void {
			Cc.log( this, "home module is ready" );
			createPaintModule();
		}

		// Paint module.
		private function createPaintModule():void {
			trace( this, "creating paint module..." );
			var paintModule:PaintModule = new PaintModule( _coreModule );
			paintModule.moduleReadySignal.addOnce( onPaintModuleReady );
			paintModule.initialize();
		}
		private function onPaintModuleReady( coreInjector:Injector ):void {
		     Cc.log( this, "paint module is ready" );

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
