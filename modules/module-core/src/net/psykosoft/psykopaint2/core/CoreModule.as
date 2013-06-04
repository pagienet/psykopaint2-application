package net.psykosoft.psykopaint2.core
{

	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;

	import com.bit101.MinimalComps;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	import net.psykosoft.notifications.NotificationsExtension;
	import net.psykosoft.notifications.events.NotificationExtensionEvent;
	import net.psykosoft.psykopaint2.base.utils.ModuleBase;
	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;
	import net.psykosoft.psykopaint2.base.utils.PlatformUtil;
	import net.psykosoft.psykopaint2.base.utils.ShakeAndBakeConnector;
	import net.psykosoft.psykopaint2.base.utils.StackUtil;
	import net.psykosoft.psykopaint2.base.utils.XMLLoader;
	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.config.CoreConfig;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.notifications.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestGpuRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;

	import org.osflash.signals.Signal;
	import org.swiftsuspenders.Injector;

	public class CoreModule extends ModuleBase
	{
		[Embed(source="../../../../../../../modules/module-core/assets/embedded/images/launch/ipad-hr/Default-Landscape@2x.png")]
		private var SplashImageAsset:Class;

		private var _coreConfig:CoreConfig;
		private var _injector:Injector;
		private var _stage3dInitialized:Boolean;
		private var _shakeAndBakeInitialized:Boolean;
		private var _shakeAndBakeConnector:ShakeAndBakeConnector;
		private var _stateSignal:RequestStateChangeSignal;
		private var _requestGpuRenderingSignal:RequestGpuRenderingSignal;
		private var _stage3d:Stage3D;
		private var _time:Number = 0;
		private var _statsTextField:TextField;
		private var _versionTextField:TextField;
		private var _errorsTextField:TextField;
		private var _fpsStackUtil:StackUtil;
		private var _renderTimeStackUtil:StackUtil;
		private var _stage3dProxy:Stage3DProxy;
		private var _coreRootView:CoreRootView;
		private var _notificationsExtension:NotificationsExtension;
		private var _memoryWarningNotification:NotifyMemoryWarningSignal;
		private var _requestNavigationToggleSignal:RequestNavigationToggleSignal;
		private var _xmLoader:XMLLoader;
		private var _splashScreen:Bitmap;
		private var _frontLayer:Sprite;
		private var _backLayer:Sprite;
		private var _fps:Number = 0;
		private var _splashScreenRemoved:Boolean;
		private var _errorCount:uint;

		public var updateActive:Boolean = true;

		public var splashScreenRemovedSignal:Signal;

		public function CoreModule( injector:Injector = null ) {
			super();
			_injector = injector;
			splashScreenRemovedSignal = new Signal();
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "CoreModule";
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function addModuleDisplay( child:DisplayObject ):void {
			_coreRootView.addToMainLayer( child );
		}

		// ---------------------------------------------------------------------
		// Loop.
		// ---------------------------------------------------------------------

		private function update():void {
			if( !updateActive ) return;
			_requestGpuRenderingSignal.dispatch();
			evalFPS();
			updateStats();
		}

		private function evalFPS():void {
			var oldTime:Number = _time;
			_time = getTimer();
			_fps = 1000 / (_time - oldTime);
			_fpsStackUtil.pushValue( _fps );
			_fps = int( _fpsStackUtil.getAverageValue() );
//			trace( ">>> fps: " + _fps );
		}

		private function updateStats():void {
			if( !CoreSettings.SHOW_STATS ) return;

			_renderTimeStackUtil.pushValue( RenderGpuCommand.renderTime );
			var renderTime:int = int( _renderTimeStackUtil.getAverageValue() );

			_statsTextField.text = _fps + "/" + stage.frameRate + "fps \n" + "Render time: " + renderTime + "ms";
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
					_requestNavigationToggleSignal.dispatch();
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

		private function onGlobalError( event:UncaughtErrorEvent ):void {
			_errorCount++;
			var error:Error = Error( event.error );
			var stack:String = error.getStackTrace();
			_errorsTextField.htmlText += "<font color='#FF0000'><b>RUNTIME ERROR - " + _errorCount + "</b></font>: " + error + " - stack: " + stack + "<br>";
			_errorsTextField.visible = true;
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function get injector():Injector {
			return _injector;
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initialize():void {

			addChild( _backLayer = new Sprite() );
			addChild( _frontLayer = new Sprite() );

			getXmlData();
			initDebugging();

			trace( this, "Initializing... [" + name + "]" );

			initPlatform();
			initPsykoSocket();
			getSplashScreen();
			initStage();
			initStage3dASync();
			initRobotlegs();
			initMemoryWarnings();
			initShakeAndBakeAsync();
		}

		private function getSplashScreen():void {
			_splashScreen = new SplashImageAsset();
			_splashScreen.transform.colorTransform = new ColorTransform( -1, -1, -1,1, 255, 255, 255 );
			_frontLayer.addChild( _splashScreen );
			_splashScreen.scaleX = _splashScreen.scaleY = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 1 : 0.5;
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
		}

		private function initStats():void {
			if( !CoreSettings.SHOW_STATS ) return;
			_fpsStackUtil = new StackUtil();
			_renderTimeStackUtil = new StackUtil();
			_fpsStackUtil.count = 24;
			_renderTimeStackUtil.count = 24;
			_statsTextField = new TextField();
			_statsTextField.width = 200;
			_statsTextField.selectable = false;
			_statsTextField.mouseEnabled = false;
			_statsTextField.scaleX = _statsTextField.scaleY = ViewCore.globalScaling;
			_backLayer.addChild( _statsTextField );
		}

		private function initVersionDisplay():void {
			if( CoreSettings.SHOW_VERSION ) {
				_versionTextField = new TextField();
				_versionTextField.scaleX = _versionTextField.scaleY = ViewCore.globalScaling;
				_versionTextField.width = 200;
				_versionTextField.mouseEnabled = _versionTextField.selectable = false;
				_versionTextField.text = CoreSettings.NAME + ", version: " + CoreSettings.VERSION;
				_versionTextField.y = ViewCore.globalScaling * 25;
				_backLayer.addChild( _versionTextField );
			}
		}

		private function initErrorDisplay():void {
			if( CoreSettings.SHOW_ERRORS ) {
				loaderInfo.uncaughtErrorEvents.addEventListener( UncaughtErrorEvent.UNCAUGHT_ERROR, onGlobalError );
				_errorsTextField = new TextField();
				_errorsTextField.scaleX = _errorsTextField.scaleY = ViewCore.globalScaling;
				_errorsTextField.width = 520 * ViewCore.globalScaling;
				_errorsTextField.height = 250 * ViewCore.globalScaling;
				_errorsTextField.x = ( 1024 - 520 - 1 ) * ViewCore.globalScaling;
				_errorsTextField.y = ViewCore.globalScaling;
				_errorsTextField.background = true;
				_errorsTextField.border = true;
				_errorsTextField.borderColor = 0xFF0000;
				_errorsTextField.multiline = true;
				_errorsTextField.wordWrap = true;
				_errorsTextField.visible = false;
				_frontLayer.addChild( _errorsTextField );
			}
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
				ViewCore.globalScaling = 2;
				// TODO: remove ( temporary )
				MinimalComps.globalScaling = 2;
			}

			trace( this, "initializing platform - " +
					"running on iPad: " + CoreSettings.RUNNING_ON_iPAD + "," +
					"running on HD: " + CoreSettings.RUNNING_ON_RETINA_DISPLAY + ", " +
					"global scaling: " + ViewCore.globalScaling
			);
		}

		private function initPsykoSocket():void {
			//adding this early on so it can be used for logging, too
			//PsykoSocket.init( CoreSettings.DEFAULT_PSYKOSOCKET_IP );
		}

		private function initStage():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW; // Note: On Desktop, the quality will be set to a lowest value of HIGH.
			stage.stageWidth = ViewCore.globalScaling * 1024;
			stage.stageHeight = ViewCore.globalScaling * 768;
//			trace( this, "initializing stage - dimensions: " + stage.stageWidth + "x" + stage.stageHeight );
		}

		private function initStage3dASync():void {
			trace( this, "initializing stage3d..." );
			var stage3dManager:Stage3DManager = Stage3DManager.getInstance( stage );
			_stage3dProxy = stage3dManager.getFreeStage3DProxy();
			_stage3dProxy.width = 1024 * ViewCore.globalScaling;
			_stage3dProxy.height = 768 * ViewCore.globalScaling;
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
			_coreRootView = new CoreRootView();
			_coreRootView.allViewsReadySignal.addOnce( onViewsReady );
			_backLayer.addChild( _coreRootView );
		}

		private function onViewsReady():void {

			initStats();
			initVersionDisplay();
			initErrorDisplay();

			// Initial application state.
			_stateSignal.dispatch( StateType.STATE_IDLE );

			// Start main enterframe.
			addEventListener( Event.ENTER_FRAME, onEnterFrame );

			// Start another enterframe to evaluate when to remove the splash image ( will be removed shortly ).
			addEventListener( Event.ENTER_FRAME, onSplashEnterFrame );

			// Notify.
			moduleReadySignal.dispatch();
		}

		private function onSplashEnterFrame( event:Event ):void {
			var targetFPS:Number = 30;
			trace( this, "waiting for frame rate to increase before removing splash screen - current fps: " + _fps + "/60, minimum: " + targetFPS );
			if( !_splashScreenRemoved && _fps >= targetFPS ) {

				trace( this, "--- SPLASH REMOVED ---" );
				removeEventListener( Event.ENTER_FRAME, onSplashEnterFrame );
				removeSplashScreen();

				if( isStandalone ) {
					// Show navigation.
					var showNavigationSignal:RequestNavigationToggleSignal = injector.getInstance( RequestNavigationToggleSignal );
					showNavigationSignal.dispatch();
				}
			}
		}

		private function removeSplashScreen():void {
			_frontLayer.removeChild( _splashScreen );
			_splashScreen.bitmapData.dispose();
			_splashScreen = null;
			_splashScreenRemoved = true;
			splashScreenRemovedSignal.dispatch();
		}
	}
}
