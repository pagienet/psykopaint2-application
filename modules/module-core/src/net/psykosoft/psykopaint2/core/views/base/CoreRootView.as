package net.psykosoft.psykopaint2.core.views.base
{

	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.TweenPlugin;

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
		private var _blocker:Sprite;

		public function CoreRootView() {
			super();

			trace( this, "constructor" );

			// Used to color button labels.
			TweenPlugin.activate( [ ColorMatrixFilterPlugin ] );

			_blocker = new Sprite();
			_blocker.graphics.beginFill( 0x000000, CoreSettings.SHOW_BLOCKER ? 0.75 : 0 );
			_blocker.graphics.drawRect( 0, 0, 1024 * CoreSettings.GLOBAL_SCALING, 768 * CoreSettings.GLOBAL_SCALING );
			_blocker.graphics.endFill();
			_blocker.visible = false;
			addChild( _blocker );

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
		}

		public function addToMainLayer( child:DisplayObject ):void {
			addChildAt( child, 0 );
		}

		public function showBlocker( block:Boolean ):void {
			_blocker.visible = block;
		}
	}
}
