package net.psykosoft.psykopaint2.core.views.popups.tutorial
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import net.psykosoft.psykopaint2.base.utils.events.EventStopper;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.SimpleVideoPlayer;
	
	import org.osflash.signals.Signal;
	
	public class TutorialPopup extends Sprite
	{
		public var closeBtn:MovieClip;
		public var bg:Sprite;
		public var dragArea:Sprite;
		
		public var onTutorialPopupCloseSignal:Signal = new Signal();;

		
		//private var videoPlayer:SimpleVideoPlayer;
		private var duration:Number=0;
		private var ns:NetStream;
		
		
		
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
			play();
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			
			ns.seek(this.mouseX/this.stage.stageWidth*duration);
		}		
		
		
		protected function onMouseUp(event:MouseEvent):void
		{
			
			this.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			this.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function initializeIntroVideo():void {
			/*videoPlayer = new SimpleVideoPlayer();
			videoPlayer.source = "core-packaged/video/GettingStarted.flv";
			videoPlayer.loop = false;
			videoPlayer.removeOnComplete = true;
			videoPlayer.width = 640;
			videoPlayer.height = 480;
			addChildAt( videoPlayer.container,0 );
			videoPlayer.container.x = (1024-videoPlayer.width)/2;
			videoPlayer.container.y = (768-videoPlayer.height)/2;
			
			
			
			var client:Object = new Object(); //Create an Object that represents the client
			client.onMetaData = onMetaData; //reference the function that catches the MetaData of the Video
			//Once MetaData is available, it'll call onMetaData with all of the information
			videoPlayer.ns.client = client;   
			*/
			function onMetaData(metaData:Object):void
			{
				duration = metaData.duration;   //duration is the variable that is supposed to total length of the video
			}
			
			
			
			//play();
			
			
			
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			var client:Object = new Object(); //Create an Object that represents the client
			client.onMetaData = onMetaData; //reference the function that catches the MetaData of the Video
			ns.client = client;             //assign our client Object to the client property of the NetStream
			
			
			ns.play("core-packaged/video/GettingStarted.flv");
			
			
			
			 function onCuePoint( info:Object ) : void { }
			
			stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, _onStageVideoAvailability);
			
		}
		
		 
		
		private function _onStageVideoAvailability ( evt : StageVideoAvailabilityEvent ) : void {
			//log the availability of StageVideo
			//if StageVideo is available
			if ( evt.availability ){
				//call _enableStageVideo
				var video:StageVideo = stage.stageVideos[0];
				video.viewPort = new Rectangle ( (1024-640)/2*CoreSettings.GLOBAL_SCALING , (768-480)/2*CoreSettings.GLOBAL_SCALING , 640*CoreSettings.GLOBAL_SCALING , 480*CoreSettings.GLOBAL_SCALING ) ;
				video.attachNetStream (ns);
				
				//HIDE ALL STAGE3d INSTANCES:
				var stage3ds:Vector.<Stage3D> = stage.stage3Ds;
				trace(stage3ds);
				for (var i:int = 0; i < stage3ds.length; i++) 
				{
					stage3ds[i].visible=false;
				}
			}else {
				//otherwise call _disableStageVideo
			//	_disableStageVideo ( ) ;
				trace("NOT AVAILABLE SORRY!!!")
			}
		}
		
		
		public function play():void{
			//videoPlayer.play();
		}
		
		
		
		protected function onMouseDownCloseBtn(event:MouseEvent):void
		{
			
			closeBtn.gotoAndStop(2);
			
		}
		
		protected function onMouseUpCloseBtn(event:MouseEvent):void
		{
			//SHOW BACK ALL STAGE3d INSTANCES:
			var stage3ds:Vector.<Stage3D> = stage.stage3Ds;
			trace(stage3ds);
			for (var i:int = 0; i < stage3ds.length; i++) 
			{
				stage3ds[i].visible=true;
			}
			
			dispose();
		}
		
		public function dispose():void{
			
			dragArea.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDownCloseBtn);
			closeBtn.removeEventListener(MouseEvent.MOUSE_UP,onMouseUpCloseBtn);
			
			//videoPlayer.stop();
			//videoPlayer.dispose();
			//videoPlayer = null;
			ns.close();
			stage.stageVideos[0].attachNetStream(null);
			EventStopper.removeStop(bg);
			
			this.parent.removeChild(this);
			
			
			
			onTutorialPopupCloseSignal.dispatch();
			
		}
	}
	/*
	private function toggleStageVideo(on:Boolean):void       
	{              
		// if StageVideo is available, attach the NetStream to StageVideo       
		if (on)       
		{       
			stageVideoInUse = true;       
			if ( sv == null )       
			{       
				sv = stage.stageVideos[0];       
				sv.addEventListener(StageVideoEvent.RENDER_STATE, stageVideoStateChange);       
			}       
			sv.attachNetStream(ns);       
			if (classicVideoInUse)       
			{       
				// If using StageVideo, just remove the Video object from       
				// the display list to avoid covering the StageVideo object       
				// (always in the background)       
				stage.removeChild ( video );       
				classicVideoInUse = false;       
			}       
		} else       
		{       
			// Otherwise attach it to a Video object       
			if (stageVideoInUse)       
				stageVideoInUse = false;       
			classicVideoInUse = true;       
			video.attachNetStream(ns);       
			stage.addChildAt(video, 0);       
		}       
		if ( !played )       
		{       
			played = true;       
			ns.play(FILE_NAME);       
		}       
	}       */
	
}