package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.debug.DebugView;
	import net.psykosoft.psykopaint2.core.views.debug.ErrorsView;
	import net.psykosoft.psykopaint2.core.views.navigation.SbNavigationView;
	import net.psykosoft.psykopaint2.core.views.popups.PopUpManagerView;
	import net.psykosoft.psykopaint2.core.views.socket.PsykoSocketView;
	import net.psykosoft.psykopaint2.core.views.splash.SplashView;
	import net.psykosoft.psykopaint2.core.views.video.VideoView;

	public class CoreRootView extends Sprite
	{
		public function CoreRootView() {
			super();

			trace( this, "constructor" );

			// Core module's main views.
			addChild( new SbNavigationView() );
			addChild( new VideoView() );
			addChild( new PopUpManagerView() );
			addChild( new DebugView() );
			addChild( new ErrorsView() );
			if( CoreSettings.ENABLE_PSYKOSOCKET_CONNECTION ) {
				addChild( new PsykoSocketView() );
			}
			addChild( new SplashView() );

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
		}

		public function addToMainLayer( child:DisplayObject ):void {
			addChildAt( child, 0 );
		}
	}
}
