package net.psykosoft.psykopaint2.core.views.base
{

	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.TweenPlugin;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

	import net.psykosoft.psykopaint2.base.ui.base.RootViewBase;
	import net.psykosoft.psykopaint2.base.utils.misc.StackUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.SimpleVideoPlayer;
	import net.psykosoft.psykopaint2.core.views.navigation.SbNavigationView;
	import net.psykosoft.psykopaint2.core.views.popups.PopUpManagerView;
	import net.psykosoft.psykopaint2.core.views.socket.PsykoSocketView;

	public class CoreRootView extends RootViewBase
	{
		// TODO: embed lower res on non retina?
		[Embed(source="../../../../../../../../../modules/module-core/assets/embedded/images/launch/ipad-hr/Default-Landscape@2x.png")]
		public static var SplashImageAsset:Class;

		[Embed(source="../../../../../../../../../modules/module-core/assets/packaged/core-packaged/swf/quotes.swf", symbol="quotes")]
		private var QuotesAsset:Class;

		private var _splashScreen:Sprite;
		private var _splashScreenBM:Bitmap;
		private var _quotes:MovieClip;

		private var _applicationLayer:Sprite;
		private var _debugLayer:Sprite;
		private var _blocker:Sprite;

		public function CoreRootView() {
			super();

			trace( this, "constructor" );

			// Used to color button labels.
			TweenPlugin.activate( [ ColorMatrixFilterPlugin ] );

			// Setup root layers.
			_applicationLayer = new Sprite();
			_applicationLayer.name = "application layer";
			_applicationLayer.mouseEnabled = false;
			addChild( _applicationLayer );

			_blocker = new Sprite();
			_blocker.graphics.beginFill( 0x000000, CoreSettings.SHOW_BLOCKER ? 0.75 : 0 );
			_blocker.graphics.drawRect( 0, 0, 1024 * CoreSettings.GLOBAL_SCALING, 768 * CoreSettings.GLOBAL_SCALING );
			_blocker.graphics.endFill();
			_blocker.visible = false;
			addChild( _blocker );

			_debugLayer = new Sprite();
			_debugLayer.name = "debug layer";
			_debugLayer.mouseEnabled = false;
			addChild( _debugLayer );

			//not sure if this is bad, but it does not seem to be harmful either
			//mouseEnabled = false;
			//moved to RootViewBase
			
			initSplashScreen();
		}

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function initialize():void {

			//this is only here for testing purposes:
			if ( CoreSettings.SHOW_INTRO_VIDEO )
			{
				var videoPlayer:SimpleVideoPlayer = new SimpleVideoPlayer();
				videoPlayer.source = "core-packaged/video/TransparentVideo.flv";
				videoPlayer.loop = false;
				videoPlayer.removeOnComplete = true;
				videoPlayer.play();
				videoPlayer.width = stage.stageWidth;
				videoPlayer.height = stage.stageHeight;
				_applicationLayer.addChild( videoPlayer.container );
			}
			// Core module's main views.
			addRegisteredView( new SbNavigationView(), _applicationLayer );
			addRegisteredView( new PopUpManagerView(), _applicationLayer );
			if( CoreSettings.ENABLE_PSYKOSOCKET_CONNECTION ) {
				addRegisteredView( new PsykoSocketView(), _applicationLayer );
			}
		}

		public function addToMainLayer( child:DisplayObject ):void {
			_applicationLayer.addChildAt( child, 0 );
		}

		public function removeSplashScreen():void {
			trace( this, "removing splash ---" );
			_debugLayer.removeChild( _splashScreen );
			_splashScreenBM.bitmapData.dispose();
			_splashScreenBM = null;
			_quotes = null;
			_splashScreen = null;
		}

		// ---------------------------------------------------------------------
		// Private
		// ---------------------------------------------------------------------

		private function initSplashScreen():void {

			_splashScreen = new Sprite();
			_debugLayer.addChild( _splashScreen );

			_splashScreenBM = new SplashImageAsset();
			_splashScreenBM.scaleX = _splashScreenBM.scaleY = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 1 : 0.5;
			_splashScreenBM.name = "splash screen";
			if( CoreSettings.TINT_SPLASH_SCREEN ) {
				_splashScreenBM.transform.colorTransform = new ColorTransform( -1, -1, -1, 1, 255, 255, 255 );
			}
			_splashScreen.addChild( _splashScreenBM );
			_quotes = MovieClip( new QuotesAsset() );
			_quotes.scaleX = _quotes.scaleY = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1;
			_quotes.x = 0;
			_quotes.y = 50 * CoreSettings.GLOBAL_SCALING;
			_quotes.gotoAndStop( Math.floor( 16 * Math.random() ) + 1 );
			_splashScreen.addChild( _quotes );
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
			/*var bmd:BitmapData = new TrackedBitmapData( 1024, 1024, false, 0 );
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
			 combobox.addItem( { label:"item" + i } );
			 }
			 combobox.x = 100;
			 combobox.y = 200;
			 addChild( combobox );*/

			// Test ButtonGroup.
			/*var b1:SbButton = new SbButton();
			 var b2:SbButton = new SbButton();
			 b2.labelText = "btn2";
			 var b3:SbButton = new SbButton();
			 var b4:SbButton = new SbButton();
			 var group:ButtonGroup = new ButtonGroup();
			 group.x = group.y = 200;
			 addChild( group );
			 group.addButton( b1 );
			 group.addButton( b2 );
			 group.addButton( b3 );
			 group.addButton( b4 );
			 group.setButtonSelected( b2.labelText );
			 this.graphics.lineStyle( 1, 0xFF0000, 1 );
			 this.graphics.drawRect( 200, 200, group.width, group.height );
			 this.graphics.endFill();*/

			// Test HItemScroller.

			/*var scroller:HItemScroller = new HItemScroller();
			scroller.x = 200;
			scroller.y = 200;
			addChild( scroller );

			var b1:SbButton = new SbButton();
			var b2:SbButton = new SbButton();
			var b3:SbButton = new SbButton();
			var b4:SbButton = new SbButton();
			var b5:SbButton = new SbButton();
			var b6:SbButton = new SbButton();
			var b7:SbButton = new SbButton();
			var b8:SbButton = new SbButton();

			var group:ButtonGroup = new ButtonGroup();
			group.addButton( b2 );
			group.addButton( b3 );
			group.addButton( b4 );
			group.addButton( b5 );
			group.addButton( b6 );
			group.addButton( b7 );
			group.addButton( b8 );

			scroller.addItem( b1 );
			scroller.addItem( group, false );
			scroller.invalidateContent();

			this.graphics.lineStyle( 1, 0xFF0000, 1 );
			this.graphics.drawRect( 200, 200, scroller.width, scroller.height );
			this.graphics.endFill();

			stage.addEventListener( MouseEvent.MOUSE_DOWN, function ( event:Event ):void {
				scroller.evaluateInteractionStart();
			} );
			stage.addEventListener( MouseEvent.MOUSE_UP, function ( event:Event ):void {
				scroller.evaluateInteractionEnd();
			} );*/

			// HSnapList test.
			/*var i:uint;
			var list:HSnapList = new HSnapList();
			list.setVisibleDimensions( 724, 150 );
			list.x = 150;
			list.y = 768 - 150;
			addChild( list );
			var dataProvider:Vector.<ISnapListData> = new Vector.<ISnapListData>();
			for( i = 0; i < 7750; i++ ) {
				var itemData:DummyItemData = new DummyItemData();
				itemData.itemRendererType = DummyItemRenderer;
				itemData.itemRendererWidth = 100;
				itemData.label = "item " + i;
				dataProvider.push( itemData );
			}
			list.setDataProvider( dataProvider );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, function ( event:Event ):void {
				list.evaluateInteractionStart();
			} );
			stage.addEventListener( MouseEvent.MOUSE_UP, function ( event:Event ):void {
				list.evaluateInteractionEnd();
			} );*/
		}

		public function showBlocker( block:Boolean ):void {
			_blocker.visible = block;
		}
	}
}
