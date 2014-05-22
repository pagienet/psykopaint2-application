package net.psykosoft.psykopaint2.core.views.video
{

	import flash.display.Sprite;
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.SimpleVideoPlayer;

	public class VideoView extends Sprite
	{
		public function VideoView() {
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			if( CoreSettings.SHOW_INTRO_VIDEO ) {
				initializeIntroVideo();
			}
		}

		private function initializeIntroVideo():void {
			var videoPlayer:SimpleVideoPlayer = new SimpleVideoPlayer();
			videoPlayer.source = "core-packaged/video/TransparentVideo.flv";
			videoPlayer.loop = false;
			videoPlayer.removeOnComplete = true;
			videoPlayer.play();
			videoPlayer.width = stage.stageWidth;
			videoPlayer.height = stage.stageHeight;
			addChild( videoPlayer.container );
		}
	}
}
