package net.psykosoft.psykopaint2.core
{

	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.utils.io.XMLLoader;
	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.core.configuration.CoreConfig;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCoreModuleBootstrapCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCoreModuleBootstrapSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestGpuRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.core.signals.RequestSplashScreenRemovalSignal;

	import robotlegs.bender.framework.api.IInjector;

	public class CoreModule extends ModuleBase
	{
		private var _coreConfig:CoreConfig;
		private var _injector:IInjector;
		private var _requestGpuRenderingSignal:RequestGpuRenderingSignal;
		private var _xmLoader:XMLLoader;
		private var _undisposedObjects : UndisposedObjects;
		private var _oldNumUndisposedObjects : uint;

		public function CoreModule( injector:IInjector = null ) {

			super();

			_undisposedObjects = UndisposedObjects.getInstance();
			_injector = injector;

			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "CoreModule";

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {

			trace( this, "added to stage" );

			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}

		private function initialize():void {

			trace( this, "initializing..." );

			CoreSettings.STAGE = stage;
			CoreSettings.DISPLAY_ROOT = this;

			getXmlData();
			initRobotlegs();
		}

		private function getXmlData():void {
			_xmLoader = new XMLLoader();
			var date:Date = new Date();
			_xmLoader.loadAsset( "common-packaged/app-data.xml?t=" + String( date.getTime() ) + Math.round( 1000 * Math.random() ), onVersionRetrieved );
		}

		private function initRobotlegs():void {

			trace( this, "initializing robotlegs" );

			_coreConfig = new CoreConfig( this );
			_injector = _coreConfig.injector;
			_requestGpuRenderingSignal = _coreConfig.injector.getInstance( RequestGpuRenderingSignal ); // Necessary for rendering the core on enter frame.

			_coreConfig.injector.getInstance( NotifyCoreModuleBootstrapCompleteSignal ).add( onBootstrapComplete );
			_coreConfig.injector.getInstance( RequestCoreModuleBootstrapSignal ).dispatch();
		}

		private function onBootstrapComplete():void {

			_coreConfig.injector.getInstance( RequestNavigationStateChangeSignal_OLD_TO_REMOVE ).dispatch( NavigationStateType.IDLE );

			if( isStandalone ) {
				_coreConfig.injector.getInstance( RequestSplashScreenRemovalSignal ).dispatch();
				startEnterFrame();
			}

			moduleReadySignal.dispatch();
		}

		// ---------------------------------------------------------------------
		//
		// ---------------------------------------------------------------------

		public function startEnterFrame():void {
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}

		private function update():void {
//			trace( this, "updating----" );
			_requestGpuRenderingSignal.dispatch();

			if (CoreSettings.TRACK_NON_GCED_OBJECTS) {
				if (_oldNumUndisposedObjects != _undisposedObjects.numObjects) {
					trace ("Number of undisposed objects changed to " + _undisposedObjects.numObjects);
					_oldNumUndisposedObjects = _undisposedObjects.numObjects;
				}
			}
		}

		private function onVersionRetrieved( data:XML ):void {

			CoreSettings.VERSION = data.version;
			trace( this, "VERSION: " + CoreSettings.VERSION );

			_xmLoader.dispose();
			_xmLoader = null;

			// TODO: feed this to CoreRootView refresh version
		}

		private function onEnterFrame( event:Event ):void {
			update();
		}

		public function get injector():IInjector {
			return _injector;
		}
	}
}
