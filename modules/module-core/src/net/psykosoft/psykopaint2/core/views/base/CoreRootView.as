package net.psykosoft.psykopaint2.core.views.base
{

	import com.bit101.components.PushButton;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.input.PsykoInput;
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
	}
}
