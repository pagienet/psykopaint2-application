package net.psykosoft.psykopaint2.core.views.base
{

import com.bit101.components.PushButton;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.system.System;

import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
import net.psykosoft.psykopaint2.core.views.debug.DebugView;
import net.psykosoft.psykopaint2.core.views.debug.ErrorsView;
import net.psykosoft.psykopaint2.core.views.navigation.NavigationView;
import net.psykosoft.psykopaint2.core.views.popups.PopUpManagerView;
import net.psykosoft.psykopaint2.core.views.socket.PsykoSocketView;
import net.psykosoft.psykopaint2.core.views.splash.SplashView;
import net.psykosoft.psykopaint2.core.views.video.VideoView;

public class CoreRootView extends Sprite
	{
		private var navigationView:NavigationView;
		
		public function CoreRootView() {
			super();

			trace( this, "constructor" );

			// Core module's main views.
			addChild( navigationView = new NavigationView() );
			addChild( new VideoView() );
			addChild( new PopUpManagerView() );
			addChild( new DebugView() );
			if( CoreSettings.ENABLE_CONSOLE ) addChild( ConsoleView.instance );
			if( CoreSettings.ENABLE_PSYKOSOCKET_CONNECTION ) addChild( new PsykoSocketView() );
			addChild( new SplashView() );
			addChild( new ErrorsView() );

			if( CoreSettings.ENABLE_GC_BUTTON ) {
				var btn:PushButton = new PushButton( this, ( 1024 - 105 ) * CoreSettings.GLOBAL_SCALING, ( 768 - 25 ) * CoreSettings.GLOBAL_SCALING, "GC()", onGcButtonClicked );
				btn.scaleX = btn.scaleY = CoreSettings.GLOBAL_SCALING;
			}

			// TODO: UI tests, remove.

//			Alert.show("hey there!");

//			var iconButton:IconButtonAlt = new IconButtonAlt();
//			iconButton.labelText = "yo";
//			iconButton.x = 250;
//			iconButton.y = 250;
//			addChild(iconButton);

			/*var btn:SbSliderButton = new SbSliderButton();
			btn.labelText = "myParam";
			btn.x = 512;
			btn.y = 512;
			btn.minValue = 50;
			btn.maxValue = 100;
			btn.value = 60;
			btn.labelMode = SbSliderButton.LABEL_VALUE;
			addChild( btn );*/

//			var input:PsykoInput = new PsykoInput();
//			input.defaultText = "email";
//			input.x = 400;
//			input.y = 200;
//			addChild( input );
//			var input1:PsykoInput = new PsykoInput();
//			input1.defaultText = "email1";
//			input1.x = 400;
//			input1.y = 400;
//			addChild( input1 );
//			input.setChainedTextField(input1);
//			setTimeout( function():void {
//				input.focusIn();
//			}, 1000 );

			// To test errors view.
//			setTimeout( function():void {
//				stage.scaleX = 2; // Will cause a runtime error.
//			}, 2000 );

//			scrollerTest();
		}

		private function onGcButtonClicked( event:MouseEvent ):void {
			System.gc();
			ConsoleView.instance.logMemory();
		}

		public function addToMainLayer( child:DisplayObject, layerOrdering:int ):void {
			switch ( layerOrdering )
			{
				case ViewLayerOrdering.AT_BOTTOM_LAYER:
					addChildAt( child, 0 );
				break;
				case ViewLayerOrdering.AT_TOP_LAYER:
					addChild( child );
					break;
				case ViewLayerOrdering.IN_FRONT_OF_NAVIGATION:
					addChildAt( child,getChildIndex(navigationView)+1);	
					break;
				case ViewLayerOrdering.BEHIND_NAVIGATION:
					addChildAt( child,getChildIndex(navigationView));	
					break;
			}
		}

		// ---------------------------------------------------------------------
		// Scroller test - Comment all below on RELEASE.
		// ---------------------------------------------------------------------

//		private var _scroller:HSnapList;
//		private var _initialPositionX:Number = 0;
//
//		private function scrollerTest():void {
//
//			// Init scroller.
//			_scroller = new HSnapList();
//			_scroller.setVisibleDimensions( 1024, 130 );
//			_scroller.setInteractionWidth( 1024 - 280 );
//			_scroller.itemGap = 25;
//			_scroller.randomPositioningRange = 5;
//			_scroller.positionManager.minimumThrowingSpeed = 15;
//			_scroller.positionManager.frictionFactor = 0.70;
//			_scroller.interactionManager.throwInputMultiplier = 2;
//			_scroller.scrollingAllowed = true;
//			_scroller.y = 150;
//			_scroller.rendererAddedSignal.add( onScrollerItemRendererAdded );
//			_scroller.rendererRemovedSignal.add( onScrollerItemRendererRemoved );
//			addChild(_scroller);
//
//			// Set data.
//			var dataProvider:Vector.<ISnapListData> = new Vector.<ISnapListData>();
//			for(var i:uint = 0; i < 3; i++) {
//
//				var btnData:ButtonData = new ButtonData();
//				btnData.labelText = btnData.defaultLabelText = "hello_" + i;
//				btnData.iconType = ButtonIconType.DEFAULT;
////				btnData.disableMouseInteractivityWhenSelected = disableMouseInteractivityWhenSelected;
////				btnData.iconBitmap = icon;
//				btnData.selectable = false;
//				btnData.id = "button_" + i;
//				btnData.itemRendererWidth = 100;
//				btnData.itemRendererType = IconButton;
//				btnData.enabled = true;
////				btnData.clickType = clickType;
////				btnData.readyCallbackObject = readyCallbackObject;
////				btnData.readyCallbackMethod = readyCallbackMethod;
//
//				dataProvider.push(btnData);
//			}
//			_scroller.setDataProvider(dataProvider);
//		}
//
//		private function onButtonClicked( event:MouseEvent ):void {
//
//			if( _scroller.isActive ) return; // Reject clicks while the scroller is moving.
//
//			var clickedButton:NavigationButton = event.target as NavigationButton;
//			if( !clickedButton ) clickedButton = event.target.parent as NavigationButton;
//			if( !clickedButton ) clickedButton = event.target.parent.parent as NavigationButton;
//			if( !clickedButton ) {
//				//throw new Error( "unidentified button clicked." );
//				//sorry - this was too annoying for debugging:
//				return;
//			}
//
//			trace("clicked: " + clickedButton.id);
//
//			_scroller.removeButton(clickedButton);
//		}
//
//		private function onScrollerItemRendererAdded( renderer:DisplayObject ):void {
//			var data:ButtonData = _scroller.getDataForRenderer( renderer );
//			renderer.addEventListener( data.clickType, onButtonClicked );
//			if ( data.readyCallbackObject )
//			{
//				data.readyCallbackMethod.apply(data.readyCallbackObject,[renderer]);
//			}
//		}
//
//		private function onScrollerItemRendererRemoved( renderer:DisplayObject ):void {
//			var data:ButtonData = _scroller.getDataForRenderer( renderer );
//			if ( data )
//			{
//				renderer.removeEventListener( data.clickType, onButtonClicked );
//			} else {
//				trace("FIXME SubNavigationViewBase.onScrollerItemRendererRemoved");
//			}
//		}
//
//		public function evaluateScrollingInteractionStart():void {
//			_scroller.evaluateInteractionStart();
//			_initialPositionX = _scroller.positionManager.position;
//		}
//
//		public function evaluateScrollingInteractionEnd():void {
//			_scroller.evaluateInteractionEnd();
//		}
//
//		public function evaluateScrollingInteractionUpdated():void
//		{
//			trace(this,"evaluateScrollingInteractionUpdated" );
//
//			//_scroller.positionManager.update();
//
//			//var shiftDistance:Number = Math.min(Math.abs(_initialPositionX - _scroller.positionManager.position),200);
//			//_scroller.y = 768 - SCROLLER_DISTANCE_FROM_BOTTOM - _scroller.visibleHeight / 2;
//
//		}
	}
}
