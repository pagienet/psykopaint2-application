package net.psykosoft.psykopaint2.core.views.popups.tutorial
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import net.psykosoft.psykopaint2.base.utils.events.EventStopper;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	
	import org.osflash.signals.Signal;
	
	public class TutorialPopup extends Sprite
	{
		public var closeBtn:MovieClip;
		public var bg:Sprite;
		public var dragArea:Sprite;
		
		public var onTutorialPopupCloseSignal:Signal = new Signal();

		
		//private var videoPlayer:SimpleVideoPlayer;
		private var duration:Number=0;
		//private var ns:NetStream;
		//private var _stagevisibilities:Array;
		private var webView:StageWebView;
		
		
		
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
			
			//dragArea.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		}
		/*
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
				//trace(stage3ds);
				_stagevisibilities = [];
				for (var i:int = 0; i < stage3ds.length; i++) 
				{
					_stagevisibilities.push(stage3ds[i].visible);
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
		
		*/
		
		protected function onMouseDownCloseBtn(event:MouseEvent):void
		{
			
			closeBtn.gotoAndStop(2);
			
		}
		
		protected function onMouseUpCloseBtn(event:MouseEvent):void
		{
			dispose();
		}
		
		public function dispose():void{
			
		//	dragArea.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDownCloseBtn);
			closeBtn.removeEventListener(MouseEvent.MOUSE_UP,onMouseUpCloseBtn);
			
			//videoPlayer.stop();
			//videoPlayer.dispose();
			//videoPlayer = null;
			//ns.close();
			//stage.stageVideos[0].attachNetStream(null);
			EventStopper.removeStop(bg);
			webView.viewPort = null;
			webView.dispose();
			this.parent.removeChild(this);
			
			
			
			onTutorialPopupCloseSignal.dispatch();
			
		}
		
		private function initializeIntroVideo():void
		{
			
			webView = new StageWebView();
			webView.stage = stage;
			var viewPort:Rectangle;
			webView.viewPort =viewPort = new Rectangle ( (1024-640)/2*CoreSettings.GLOBAL_SCALING , (768-480)/2*CoreSettings.GLOBAL_SCALING , 640*CoreSettings.GLOBAL_SCALING , 480*CoreSettings.GLOBAL_SCALING ) ;
			
			var ftarget:File = File.applicationStorageDirectory.resolvePath("GettingStartedSoftware.mp4");
			if ( !ftarget.exists )
			{
				var f:File = File.applicationDirectory.resolvePath("core-packaged/video/GettingStartedSoftware.mp4");
				f.copyTo(ftarget);
			}
			f = File.applicationStorageDirectory.resolvePath("tutorial.html");
			//TODO: video size might need a little tweaking still:
			if ( !f.exists )
			{
				var fs:FileStream = new FileStream();
				fs.open(f,FileMode.WRITE);
				fs.writeUTFBytes('<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body style="margin:0px;padding:0px;"><video src="GettingStartedSoftware.mp4" controls autoplay width="'+viewPort.width+'" height="'+viewPort.height+'"></video></body></html>');
				fs.close();
			}
			webView.loadURL(  "file://"+f.nativePath );
		}
	}
	
	
}