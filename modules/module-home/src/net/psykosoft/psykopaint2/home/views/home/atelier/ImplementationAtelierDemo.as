package net.psykosoft.psykopaint2.home.views.home.atelier
{
	import away3d.containers.View3D;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;

	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	public class ImplementationAtelierDemo extends Sprite
	{
		private var _view : View3D;
		private var _prefabOutput:Atelier;
		private var _camera:Camera3D;

		private const EXTREME:uint = 814;
		private const DOUBLE_EXTREME:uint = 1628;

		public var _time:Number = 0.3333;
		public var _startTime:Number;
		private var _startMouseX:Number;
		private var _mouseIsDown:Boolean;
		private var _mouseBooster:Number = 2.5;
		private var _step:Number = 1/3;
		private var _unlocked:Boolean;

		public function ImplementationAtelierDemo() {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.showDefaultContextMenu = true;
			stage.stageFocusRect = false;

			initView();
			stage.addEventListener(Event.RESIZE, onResize);
			initContent();
			addEventListener(Event.ENTER_FRAME, renderFrame);

			stage.addEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		private function initView():void
		{
			_view = new View3D();
			_view.antiAlias = 2;
			_view.backgroundColor = 0x222222;

			_camera = _view.camera;
			_camera.lens = new PerspectiveLens();
			_camera.lens.near = 10;
			_camera.lens.far = 5000;

			_camera.x =  -266.82;
			_camera.y = -1.14 ;
			_camera.z = -146.5;
			_camera.lookAt(new Vector3D(-266.82, -1.14, -353.10));
			 
			addChild(_view);
		}

		private function initContent():void
		{
			_prefabOutput = new Atelier();
			_view.scene.addChild(_prefabOutput);

			tweenToStart();
		}

		public function renderFrame(e:Event):void
		{
			if(_mouseIsDown) updatePosition();
			 _view.render();
		}

		private function onResize(event:Event):void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}

		//mouse stuff
		private function onStageMouseDown( event:MouseEvent ):void
		{
			_mouseIsDown = true;
			_startMouseX = mouseX;
			_startTime = _time;		 
		}
		
		private function onStageMouseUp( event:MouseEvent ):void
		{
			_mouseIsDown = false;
			snapToNearestTime();
		}

		//simulates the intro of app
		private function tweenToStart():void
 		{
			TweenLite.to(	_camera, 2.5, { 	z:450,
												ease: Strong.easeIn,
												onComplete:unlock
										} );
 		}
 		private function unlock():void
 		{
 			_unlocked = true;
 		}

		//mouse is loose, goes back to the full openned page and returns the destination time
 		private function snapToNearestTime():void
 		{
 			var currentPoint:uint = Math.round(_time/_step);
 			var nearestTime:Number = currentPoint*_step;

 			TweenLite.to( this, 1, { 	_time:nearestTime, 
 							ease: Strong.easeOut,
							onUpdate:updateToNearestTime,
							onComplete:updateToNearestTime } );
 		}

 		public function updateToNearestTime():void
 		{
 			_camera.x = -EXTREME + (_time * DOUBLE_EXTREME);
 		}

		private function updatePosition():void
		{
			var mx:Number = (mouseX-_startMouseX);
			var currentTime:Number =  ((mx*_mouseBooster)/ stage.stageWidth ) *.5;

			_time =  currentTime + _startTime;
			
			if(_time < 0) _time = 0;
			if(_time > 1) _time = 1;
			updateToNearestTime();
		}
	}
}