package net.psykosoft.psykopaint2.core
{

	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;

	import com.bit101.MinimalComps;

	import flash.display.DisplayObject;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	import net.psykosoft.notifications.NotificationsExtension;
	import net.psykosoft.notifications.events.NotificationExtensionEvent;
	import net.psykosoft.psykopaint2.base.utils.io.ShakeAndBakeConnector;
	import net.psykosoft.psykopaint2.base.utils.io.XMLLoader;
	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.base.utils.misc.PlatformUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreConfig;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestGpuRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingActivationSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingDataRetrievalSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;

	import robotlegs.bender.framework.api.IInjector;

	public class CoreModule extends ModuleBase
	{
		private var _coreConfig:CoreConfig;
		private var _injector:IInjector;
		private var _stage3dInitialized:Boolean;
		private var _shakeAndBakeInitialized:Boolean;
		private var _shakeAndBakeConnector:ShakeAndBakeConnector;
		private var _stateSignal:RequestStateChangeSignal;
		private var _requestGpuRenderingSignal:RequestGpuRenderingSignal;
		private var _stage3d:Stage3D;
		private var _stage3dProxy:Stage3DProxy;
		private var _coreRootView:CoreRootView;
		private var _notificationsExtension:NotificationsExtension;
		private var _memoryWarningNotification:NotifyMemoryWarningSignal;
		private var _requestNavigationToggleSignal:RequestNavigationToggleSignal;
		private var _xmLoader:XMLLoader;

		public function CoreModule( injector:IInjector = null ) {
			super();
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
			// TODO: remove time out, why do we need this?
			setTimeout( function():void {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}, 2000 );
		}

		// ---------------------------------------------------------------------
		// Loop.
		// ---------------------------------------------------------------------

		private function update():void {
//			trace( this, "updating----" );
			_requestGpuRenderingSignal.dispatch();
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onStageKeyDown( event:KeyboardEvent ):void {
			switch( event.keyCode ) {
				case Keyboard.M:
				{
					_memoryWarningNotification.dispatch();
					break;
				}
				case Keyboard.SPACE:
				{
					_requestNavigationToggleSignal.dispatch( 0 );
					break;
				}
			}
		}

		private function onMemoryWarning( event:NotificationExtensionEvent ):void {
			trace( this, "*** WARNING *** - AS3 knows of an iOS memory warning." );
			_memoryWarningNotification.dispatch();
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}

		private function onShakeAndBakeConnected():void {
			trace( this, "shake and bake connected" );
			_shakeAndBakeInitialized = true;
			_shakeAndBakeConnector = null;
			checkInitialized();
		}

		private function onContext3dCreated( event:Event ):void {

			trace( this, "context3d created: " + _stage3dProxy.context3D );
			_stage3dProxy.removeEventListener( Event.CONTEXT3D_CREATE, onContext3dCreated );

			// TODO: listen for context loss?
			// This simulates a context loss. A bit of googling shows that context loss on iPad is rare, but could be possible.
			/*setTimeout( function():void {
			 trace( "<<< CONTEXT3D LOSS TEST >>>" );
			 _stage3D.context3D.dispose();
			 }, 60000 );*/

			if( !_stage3dInitialized ) {
				_stage3dProxy.context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, CoreSettings.STAGE_3D_ANTI_ALIAS, true );
				_stage3dProxy.context3D.enableErrorChecking = CoreSettings.STAGE_3D_ERROR_CHECKING;
				// TODO: set stage3d props here like antialias, bg color, etc
				_stage3dInitialized = true;
				checkInitialized();
			}
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

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initialize():void {

			getXmlData();
			initDebugging();

			trace( this, "Initializing... [" + name + "]" );

			initPlatform();
			initStage();
			initDisplay();
			initStage3dASync();
			initRobotlegs();
			initMemoryWarnings();
			initShakeAndBakeAsync();
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

		private function initDebugging():void {
			// Keys
			if( CoreSettings.USE_DEBUG_KEYS ) {
				stage.addEventListener( KeyboardEvent.KEY_DOWN, onStageKeyDown );
			}
		}

		private function initPlatform():void {
			CoreSettings.RUNNING_ON_iPAD = PlatformUtil.isRunningOnIPad();
			CoreSettings.RUNNING_ON_RETINA_DISPLAY = PlatformUtil.isRunningOnDisplayWithDpi( CoreSettings.RESOLUTION_DPI_RETINA );
			if( CoreSettings.RUNNING_ON_RETINA_DISPLAY ) {
				CoreSettings.GLOBAL_SCALING = 2;
				CoreSettings.STAGE_WIDTH = 2048;
				CoreSettings.STAGE_HEIGHT = 1536;
				// TODO: remove ( temporary )
				MinimalComps.globalScaling = 2;
			}

			trace( this, "initializing platform - " +
					"running on iPad: " + CoreSettings.RUNNING_ON_iPAD + "," +
					"running on HD: " + CoreSettings.RUNNING_ON_RETINA_DISPLAY + ", " +
					"global scaling: " + CoreSettings.GLOBAL_SCALING
			);
		}

		private function initStage():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW; // Note: On Desktop, the quality will be set to a lowest value of HIGH.
			stage.stageWidth = CoreSettings.GLOBAL_SCALING * 1024;
			stage.stageHeight = CoreSettings.GLOBAL_SCALING * 768;
//			trace( this, "initializing stage - dimensions: " + stage.stageWidth + "x" + stage.stageHeight );
		}

		private function initStage3dASync():void {
			trace( this, "initializing stage3d..." );
			var stage3dManager:Stage3DManager = Stage3DManager.getInstance( stage );
			_stage3dProxy = stage3dManager.getFreeStage3DProxy();
			_stage3dProxy.width = 1024 * CoreSettings.GLOBAL_SCALING;
			_stage3dProxy.height = 768 * CoreSettings.GLOBAL_SCALING;
			_stage3d = _stage3dProxy.stage3D;
			_stage3dProxy.addEventListener( Stage3DEvent.CONTEXT3D_CREATED, onContext3dCreated );
		}

		private function initRobotlegs():void {
//			trace( this, "initRobotlegs with stage: " + stage + ", and stage3d: " + _stage3d );
			_coreConfig = new CoreConfig( this, stage, _stage3d, _stage3dProxy );
			_requestNavigationToggleSignal = _coreConfig.injector.getInstance( RequestNavigationToggleSignal );
			_requestGpuRenderingSignal = _coreConfig.injector.getInstance( RequestGpuRenderingSignal ); // Necessary for rendering the core on enter frame.
			_stateSignal = _coreConfig.injector.getInstance( RequestStateChangeSignal ); // Necessary for rendering the core on enter frame.
			_injector = _coreConfig.injector;
			trace( this, "initializing robotlegs context" );
		}

		private function initMemoryWarnings():void {
			_memoryWarningNotification = _coreConfig.injector.getInstance( NotifyMemoryWarningSignal );
			_notificationsExtension = new NotificationsExtension();
			_notificationsExtension.addEventListener( NotificationExtensionEvent.RECEIVED_MEMORY_WARNING, onMemoryWarning );
			_notificationsExtension.initialize();
		}

		private function initShakeAndBakeAsync():void {
			_shakeAndBakeConnector = new ShakeAndBakeConnector();
			_shakeAndBakeConnector.connectedSignal.addOnce( onShakeAndBakeConnected );
			var swfUrl:String = "core-packaged/swf/core-assets.swf";
			_shakeAndBakeConnector.connectAssetsAsync( this, swfUrl );
			trace( this, "initializing shake and bake: " + swfUrl + "..." );
		}

		private function checkInitialized():void {

			trace( this, "check initialized - " +
					"shakeAndBake: " + _shakeAndBakeInitialized + ", " +
					"stage3d: " + _stage3dInitialized
			);

			if( !_shakeAndBakeInitialized ) return;
			if( !_stage3dInitialized ) return;

			trace( this, "initialized" );

			// Init display tree.
			_coreRootView.runUiTests();
			_coreRootView.allViewsReadySignal.addOnce( onViewsReady );
			_coreRootView.initialize();
		}

		private function onViewsReady():void {

			_stateSignal.dispatch( StateType.IDLE );

			if( isStandalone ) {
				// Remove splash screen.
				_coreRootView.removeSplashScreen();
				// Show Navigation.
				var showNavigationSignal:RequestNavigationToggleSignal = _injector.getInstance( RequestNavigationToggleSignal );
				showNavigationSignal.dispatch( 1 );
				startEnterFrame();
			}

			// Start loading painting data.
			_injector.getInstance( RequestPaintingDataRetrievalSignal ).dispatch();
//			_injector.getInstance( NotifyPaintingDataRetrievedSignal ).addOnce( testLoadingAPainting ); // Just for testing.

			moduleReadySignal.dispatch();
		}

		private function testLoadingAPainting( data:Vector.<PaintingInfoVO> ):void {
			var aVo:PaintingInfoVO = data[ 0 ];
			trace( this, "painting data loaded, testing painting load: " + aVo.id );
			_injector.getInstance( RequestPaintingActivationSignal ).dispatch( aVo.id );
		}
	}
}
