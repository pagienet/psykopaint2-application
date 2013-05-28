package net.psykosoft.psykopaint2.home
{

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;

	import com.junkbyte.console.Cc;

	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.ModuleBase;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.home.config.HomeConfig;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;

	import org.swiftsuspenders.Injector;

	public class HomeModule extends ModuleBase
	{
		private var _coreModule:CoreModule;
		private var _view3d:View3D;

		public function HomeModule( core:CoreModule = null ) {
			super();
			trace( ">>>>> HomeModule starting..." );
			_coreModule = core;
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

			// Init 3d.
			_view3d = new View3D();
			_view3d.stage3DProxy = _coreModule.stage3dProxy;
			_view3d.shareContext = true;
			_view3d.camera.lens.far = 50000;

			// Initialize the home module.
			var config:HomeConfig = new HomeConfig( coreInjector, _view3d );

			// Init display tree for this module.
			_coreModule.addChild( new HomeRootView( _view3d ) );

			// Trigger initial state...
			config.injector.getInstance( RequestStateChangeSignal ).dispatch( StateType.HOME );

			// Notify potential super modules.
			moduleReadySignal.dispatch( coreInjector );

			// Start local enterframe is standalone.
			if( isStandalone ) {
				trace( this, " >>> starting as standalone." );
				addEventListener( Event.ENTER_FRAME, onEnterframe );
			}
		}

		private function onEnterframe( event:Event ):void {
//			trace( "rendering 3d" );
			_coreModule.stage3dProxy.clear();
			_view3d.render();
			_coreModule.stage3dProxy.present();
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
