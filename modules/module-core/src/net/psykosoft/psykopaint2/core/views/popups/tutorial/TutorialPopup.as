package net.psykosoft.psykopaint2.core.views.popups.tutorial
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.psykosoft.psykopaint2.core.views.components.SimpleVideoPlayer;
	
	public class TutorialPopup extends Sprite
	{
		public var closeBtn:MovieClip;
		private var videoPlayer:SimpleVideoPlayer;
		private var duration:Number=0;
		
		public function TutorialPopup()
		{
			
			closeBtn.stop();
			closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownCloseBtn);
			closeBtn.addEventListener(MouseEvent.MOUSE_UP,onMouseUpCloseBtn);
			
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		
		
		protected function onMouseMove(event:MouseEvent):void
		{
			
			videoPlayer.seek(this.mouseX/this.stage.stageWidth*duration);
		}		
		
		
		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			initializeIntroVideo();
			
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		private function initializeIntroVideo():void {
			videoPlayer = new SimpleVideoPlayer();
			videoPlayer.source = "core-packaged/video/gettingStarted.mp4";
			videoPlayer.loop = false;
			videoPlayer.removeOnComplete = true;
			videoPlayer.width = stage.stageWidth;
			videoPlayer.height = stage.stageHeight;
			addChildAt( videoPlayer.container,0 );
			play();
			var client:Object = new Object(); //Create an Object that represents the client
			client.onMetaData = onMetaData; //reference the function that catches the MetaData of the Video
			videoPlayer.ns.client = client;             //assign our client Object to the client property of the NetStream
			//Once MetaData is available, it'll call onMetaData with all of the information
			
			function onMetaData(metaData:Object):void
			{
				duration = metaData.duration;   //duration is the variable that is supposed to total length of the video
			}
			
		}
		
		public function play():void{
			videoPlayer.play();
		}
		
		
		
		protected function onMouseDownCloseBtn(event:MouseEvent):void
		{
			closeBtn.gotoAndStop(2);
			
		}
		
		protected function onMouseUpCloseBtn(event:MouseEvent):void
		{
			videoPlayer.stop();
			videoPlayer.dispose();
			this.parent.removeChild(this);
			closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDownCloseBtn);
			closeBtn.removeEventListener(MouseEvent.MOUSE_UP,onMouseUpCloseBtn);
			
		}
	}
}