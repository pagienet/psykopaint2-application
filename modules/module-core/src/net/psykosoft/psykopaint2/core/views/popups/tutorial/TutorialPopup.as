package net.psykosoft.psykopaint2.core.views.popups.tutorial
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.psykosoft.psykopaint2.base.utils.events.EventStopper;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.views.components.SimpleVideoPlayer;
	
	import org.osflash.signals.Signal;
	
	public class TutorialPopup extends Sprite
	{
		public var closeBtn:MovieClip;
		public var bg:Sprite;
		public var dragArea:Sprite;
		
		public var onTutorialPopupCloseSignal:Signal = new Signal();;

		
		private var videoPlayer:SimpleVideoPlayer;
		private var duration:Number=0;
		
		
		
		public function TutorialPopup()
		{
			
			
			
			
			closeBtn.stop();
			closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownCloseBtn);
			closeBtn.addEventListener(MouseEvent.MOUSE_UP,onMouseUpCloseBtn);
			
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		
		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			initializeIntroVideo();
			EventStopper.stop(bg);
			
			dragArea.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
			
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			
			videoPlayer.seek(this.mouseX/this.stage.stageWidth*duration);
		}		
		
		
		protected function onMouseUp(event:MouseEvent):void
		{
			
			this.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			this.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function initializeIntroVideo():void {
			videoPlayer = new SimpleVideoPlayer();
			videoPlayer.source = "core-packaged/video/gettingStarted.mp4";
			videoPlayer.loop = false;
			videoPlayer.removeOnComplete = true;
			videoPlayer.width = 640;
			videoPlayer.height = 480;
			addChildAt( videoPlayer.container,0 );
			videoPlayer.container.x = (1024-videoPlayer.width)/2;
			videoPlayer.container.y = (768-videoPlayer.height)/2;
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
			
			dispose();
		}
		
		public function dispose():void{
			
			dragArea.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDownCloseBtn);
			closeBtn.removeEventListener(MouseEvent.MOUSE_UP,onMouseUpCloseBtn);
			
			videoPlayer.stop();
			videoPlayer.dispose();
			videoPlayer = null;
			EventStopper.removeStop(bg);
			
			this.parent.removeChild(this);
			
			
			
			onTutorialPopupCloseSignal.dispatch();
			
		}
	}
}