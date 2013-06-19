package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.ui.base.RootViewBase;
	import net.psykosoft.psykopaint2.base.utils.StackUtil;
	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.navigation.SbNavigationView;
	import net.psykosoft.psykopaint2.core.views.socket.PsykoSocketView;

	public class CoreRootView extends RootViewBase
	{
		[Embed(source="../../../../../../../../../modules/module-core/assets/embedded/images/launch/ipad-hr/Default-Landscape@2x.png")]
		private var SplashImageAsset:Class;

		private var _time:Number = 0;
		private var _statsTextField:TextField;
		private var _versionTextField:TextField;
		private var _errorsTextField:TextField;
		private var _fpsStackUtil:StackUtil;
		private var _renderTimeStackUtil:StackUtil;
		private var _splashScreen:Bitmap;
		private var _fps:Number = 0;
		private var _errorCount:uint;
		private var _memoryIcon:TextField;
		private var _memoryIconTimer:Timer;
		private var _memoryWarningCount:uint;
		private var _applicationLayer:Sprite;
		private var _debugLayer:Sprite;

		public function CoreRootView() {
			super();

			trace( this, "constructor" );

			// Setup root layers.
			_applicationLayer = new Sprite();
			_applicationLayer.name = "application layer";
			addChild( _applicationLayer );
			_debugLayer = new Sprite();
			_debugLayer.name = "debug layer";
			_debugLayer.mouseEnabled = false;
			addChild( _debugLayer );
			
			//not sure if this is bad, but it does not seem to be harmful either
			mouseEnabled = false;
			
			initSplashScreen();
			initVersionDisplay();
			initStats();
			initErrorDisplay();
			initMemoryWarningDisplay();

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			if( CoreSettings.SHOW_ERRORS )
				loaderInfo.uncaughtErrorEvents.addEventListener( UncaughtErrorEvent.UNCAUGHT_ERROR, onGlobalError );

			// Start enterframe.
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function refreshVersion():void {
			var resMsg:String = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? "2048x1536" : "1024x768";
			_versionTextField.text = CoreSettings.NAME + ", " + resMsg + ", version: " + CoreSettings.VERSION;
		}

		public function initialize():void {
			// Core module's main views.
			addRegisteredView( new SbNavigationView(), _applicationLayer );
			if( CoreSettings.SHOW_PSYKOSOCKET_CONNECTION_UI ) {
				addRegisteredView( new PsykoSocketView(), _applicationLayer );
			}
		}

		public function addToMainLayer( child:DisplayObject ):void {
			_applicationLayer.addChildAt( child, 0 );
		}

		public function flashMemoryIcon():void {
			if( !_memoryIconTimer ) {
				_memoryIconTimer = new Timer( 5000, 1 );
				_memoryIconTimer.addEventListener( TimerEvent.TIMER, onMemoryIconTimerTick );
			}
			_memoryWarningCount++;
			_memoryIcon.text = "MEMORY WARNING: " + _memoryWarningCount;
			_memoryIconTimer.start();
			_memoryIcon.visible = true;
		}

		public function removeSplashScreen():void {
			trace( this, "removing splash ---" );
			_debugLayer.removeChild( _splashScreen );
			_splashScreen.bitmapData.dispose();
			_splashScreen = null;
		}

		// ---------------------------------------------------------------------
		// Private
		// ---------------------------------------------------------------------

		private function initMemoryWarningDisplay():void {
			if( !CoreSettings.SHOW_MEMORY_WARNINGS ) return;
			_memoryIcon = new TextField();
			_memoryIcon.name = "memory text field";
			_memoryIcon.selectable = _memoryIcon.mouseEnabled = false;
			_memoryIcon.scaleX = _memoryIcon.scaleY = CoreSettings.GLOBAL_SCALING;
			_memoryIcon.textColor = 0xFF0000;
			_memoryIcon.width = 200;
			_memoryIcon.height = 25;
			_memoryIcon.y = CoreSettings.GLOBAL_SCALING * 40;
			_debugLayer.addChild( _memoryIcon );
		}

		private function initStats():void {
			if( !CoreSettings.SHOW_STATS ) return;
			_fpsStackUtil = new StackUtil();
			_renderTimeStackUtil = new StackUtil();
			_fpsStackUtil.count = 24;
			_renderTimeStackUtil.count = 24;
			_statsTextField = new TextField();
			_statsTextField.name = "stats text field";
			_statsTextField.width = 200;
			_statsTextField.selectable = false;
			_statsTextField.mouseEnabled = false;
			_statsTextField.scaleX = _statsTextField.scaleY = CoreSettings.GLOBAL_SCALING;
			_debugLayer.addChild( _statsTextField );
		}

		private function initVersionDisplay():void {
			if( CoreSettings.SHOW_VERSION ) {
				_versionTextField = new TextField();
				_versionTextField.name = "version text field";
				_versionTextField.scaleX = _versionTextField.scaleY = CoreSettings.GLOBAL_SCALING;
				_versionTextField.width = 250;
				_versionTextField.mouseEnabled = _versionTextField.selectable = false;
				_versionTextField.y = CoreSettings.GLOBAL_SCALING * 25;
				_debugLayer.addChild( _versionTextField );
			}
		}

		private function initErrorDisplay():void {
			if( CoreSettings.SHOW_ERRORS ) {
				_errorsTextField = new TextField();
				_errorsTextField.name = "errors text field";
				_errorsTextField.scaleX = _errorsTextField.scaleY = CoreSettings.GLOBAL_SCALING;
				_errorsTextField.addEventListener( MouseEvent.MOUSE_UP, onErrorsMouseUp );
				_errorsTextField.width = 520 * CoreSettings.GLOBAL_SCALING;
				_errorsTextField.height = 250 * CoreSettings.GLOBAL_SCALING;
				_errorsTextField.x = ( 1024 - 520 - 1 ) * CoreSettings.GLOBAL_SCALING;
				_errorsTextField.y = CoreSettings.GLOBAL_SCALING;
				_errorsTextField.background = true;
				_errorsTextField.border = true;
				_errorsTextField.borderColor = 0xFF0000;
				_errorsTextField.multiline = true;
				_errorsTextField.wordWrap = true;
				_errorsTextField.visible = false;
				_debugLayer.addChild( _errorsTextField );
			}
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

		private function initSplashScreen():void {
			_splashScreen = new SplashImageAsset();
			_splashScreen.name = "splash screen";
			_splashScreen.transform.colorTransform = new ColorTransform( -1, -1, -1, 1, 255, 255, 255 );
			_debugLayer.addChild( _splashScreen );
			_splashScreen.scaleX = _splashScreen.scaleY = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 1 : 0.5;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onMemoryIconTimerTick( event:TimerEvent ):void {
			_memoryIconTimer.reset();
			_memoryIcon.visible = false;
		}

		private function onEnterFrame( event:Event ):void {
			evalFPS();
			updateStats();
		}

		private function onGlobalError( event:UncaughtErrorEvent ):void {
			_errorCount++;
			var error:Error = Error( event.error );
			var stack:String = error.getStackTrace();
			_errorsTextField.htmlText += "<font color='#FF0000'><b>RUNTIME ERROR - " + _errorCount + "</b></font>: " + error + " - stack: " + stack + "<br>";
			_errorsTextField.visible = true;
		}

		private function onErrorsMouseUp( event:MouseEvent ):void {
			_errorsTextField.visible = false;
		}

		// ---------------------------------------------------------------------
		// Ui tests...
		// ---------------------------------------------------------------------

		// TODO: remove
		public function runUiTests():void {

			// Bg fill.
			/*this.graphics.beginFill(0xCCCCCC, 1.0);
			 this.graphics.drawRect(0, 0, 1024, 768);
			 this.graphics.endFill();*/

			// Find out what view element is clicked.
			/*stage.addEventListener( MouseEvent.MOUSE_DOWN, function ( event:Event ):void {
			 trace( this, "stage mouse down --------------------------" );
			 trace( "listing objects under mouse..." );
			 var pt:Point = new Point( stage.mouseX, stage.mouseY );
			 var objects:Array = getObjectsUnderPoint( pt );
			 for( var i:int = 0; i < objects.length; i++ ) {
			 trace( "-", objects[i].name, ": ", objects[i] );
			 }
			 trace( "object clicked hierarchy..." );
			 var p:* = event.target;
			 var off:String = ">";
			 while( p ) {
			 trace( off, p.name, ": ", p );
			 p = p.parent;
			 off += ">";
			 }
			 } );*/

			// Tile sheet.
			// Source bmd sheet.
			/*var bmd:BitmapData = new BitmapData( 1024, 1024, false, 0 );
			 bmd.perlinNoise( 50, 50, 1, 1, false, true, 7, false );
			 // Component.
			 var tileSheet:TileSheet = new TileSheet();
			 tileSheet.visibleWidth = 1024;
			 tileSheet.visibleHeight = 768;
			 addChild( tileSheet );
			 // Population.
			 var tileSize:uint = 128;
			 var numTiles:uint = 160;
			 tileSheet.initializeWithProperties( numTiles, tileSize );
			 for( var i:uint; i < numTiles; ++i ) {
			 var tileSheetX:Number = ( 1024 - tileSize ) * Math.random();
			 var tileSheetY:Number = ( 1024 - tileSize ) * Math.random();
			 tileSheet.setTileContentFromSpriteSheet( bmd, tileSheetX, tileSheetY );
			 }
			 // Interaction.
			 stage.addEventListener( MouseEvent.MOUSE_DOWN, function( event:Event ):void {
			 tileSheet.evaluateInteractionStart();
			 } );
			 stage.addEventListener( MouseEvent.MOUSE_UP, function( event:Event ):void {
			 tileSheet.evaluateInteractionEnd();
			 } );*/

			// User photos tile sheet.
			// Component.
			/*var tileSheet:UserPhotosTileSheet = new UserPhotosTileSheet();
			tileSheet.visibleWidth = 1024;
			tileSheet.visibleHeight = 768;
			addChild( tileSheet );
			// Interaction.
			stage.addEventListener( MouseEvent.MOUSE_DOWN, function ( event:Event ):void {
				tileSheet.evaluateInteractionStart();
			} );
			stage.addEventListener( MouseEvent.MOUSE_UP, function ( event:Event ):void {
				tileSheet.evaluateInteractionEnd();
			} );
			setTimeout( function():void {
				tileSheet.fetchPhotos();
			}, 3000 );*/

			// Simple slider test.
			/*var simpleSlider:SbSlider = new SbSlider();
			 simpleSlider.x = 200;
			 simpleSlider.y = 20;
			 simpleSlider.value = 0.7;
			 simpleSlider.minValue = 0.5;
			 simpleSlider.maxValue = 0.75;
			 simpleSlider.addEventListener( Event.CHANGE, function( event:Event ):void {
			 trace( ">>> simple slider change: " + simpleSlider.value );
			 } );
			 addChild( simpleSlider );*/

			// Range slider test.
		/*	var container:Sprite = new Sprite();
			 container.scaleX = container.scaleY = 1;
			 addChild( container );
			 var rangeSlider:SbRangedSlider = new SbRangedSlider();
			 rangeSlider.x = 1024 / 2 - rangeSlider.width / 2;
			 rangeSlider.y = 768 / 2;
			 rangeSlider.minValue = 0;
			 rangeSlider.maxValue = 1;
			 rangeSlider.value1 = 0;
			 rangeSlider.value2 = 1;
			 rangeSlider.addEventListener( Event.CHANGE, function( event:Event ):void {
			 //				trace( ">>> range slider change: " + rangeSlider.value1 + ", " + rangeSlider.value2 );
			 } );
			 container.addChild( rangeSlider );*/

			//CheckBox test.
			 /*var checkbox:SbCheckBox = new SbCheckBox();
			 checkbox.x = 50;
			 checkbox.y = 20;
			 addChild( checkbox );*/

			//Combobox test.
			/*var combobox:SbComboboxView = new SbComboboxView();
			 for( var i:uint; i < 10; i++ ) {
			 combobox.addItem( { label:"item_" + i } );
			 }
			 combobox.x = 100;
			 combobox.y = 200;
			 addChild( combobox );*/
		}
	}
}
