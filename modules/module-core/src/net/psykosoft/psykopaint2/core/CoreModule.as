package net.psykosoft.psykopaint2.core
{

	import flash.display.DisplayObject;
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
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;

	import robotlegs.bender.framework.api.IInjector;

	public class CoreModule extends ModuleBase
	{
		private var _coreConfig:CoreConfig;
		private var _injector:IInjector;
		private var _requestGpuRenderingSignal:RequestGpuRenderingSignal;
		private var _coreRootView:CoreRootView;
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

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function addModuleDisplay( child:DisplayObject ):void {
			trace( this, "adding module display: " + child );
			_coreRootView.addToMainLayer( child );
		}

		public function startEnterFrame():void {
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}

		// ---------------------------------------------------------------------
		// Loop.
		// ---------------------------------------------------------------------

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

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initialize():void {
			trace( this, "Initializing... [" + name + "]" );
			initRobotlegs();
			getXmlData();
			initDisplay();
		}

		private function getXmlData():void {
			_xmLoader = new XMLLoader();
			var date:Date = new Date();
			_xmLoader.loadAsset( "common-packaged/app-data.xml?t=" + String( date.getTime() ) + Math.round( 1000 * Math.random() ), onVersionRetrieved );
		}

		private function onVersionRetrieved( data:XML ):void {

			CoreSettings.VERSION = data.version;
			trace( this, "VERSION: " + CoreSettings.VERSION );

			_xmLoader.dispose();
			_xmLoader = null;
			_coreRootView.refreshVersion();
		}

		private function initDisplay():void {
			_coreRootView = new CoreRootView();
			addChild( _coreRootView );
		}

		private function initRobotlegs():void {

//			trace( this, "initRobotlegs with stage: " + stage + ", and stage3d: " + _stage3d );
			_coreConfig = new CoreConfig( this );
			_requestGpuRenderingSignal = _coreConfig.injector.getInstance( RequestGpuRenderingSignal ); // Necessary for rendering the core on enter frame.
			_injector = _coreConfig.injector;
			trace( this, "initializing robotlegs context" );

			_coreConfig.injector.getInstance( NotifyCoreModuleBootstrapCompleteSignal ).add( initializeCoreRootView );
			_coreConfig.injector.getInstance( RequestCoreModuleBootstrapSignal ).dispatch( stage );
		}

		private function initializeCoreRootView():void {

			trace( this, "initialized" );

			// Init display tree.
			_coreRootView.runUiTests();
			_coreRootView.allViewsReadySignal.addOnce( onViewsReady );
			_coreRootView.initialize();
		}

		private function onViewsReady():void {

			_coreConfig.injector.getInstance( RequestNavigationStateChangeSignal_OLD_TO_REMOVE ).dispatch( NavigationStateType.IDLE );

			if( isStandalone ) {

				// Remove splash screen.
				_coreRootView.removeSplashScreen();

				startEnterFrame();
			}

			moduleReadySignal.dispatch();
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}

		private function onEnterFrame( event:Event ):void {
			update();
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function get injector():IInjector {
			return _injector;
		}

		public function get coreRootView():CoreRootView {
			return _coreRootView;
		}
	}
}
