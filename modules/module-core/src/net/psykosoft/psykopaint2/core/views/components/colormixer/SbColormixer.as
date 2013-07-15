package net.psykosoft.psykopaint2.core.views.components.colormixer
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	

	public class SbColormixer extends Sprite
	{
		private var _id : String;
		
		private var mapDisplay:Bitmap;
		private var _displayMap:BitmapData;
		private var _displacementMap:BitmapData;
		private var _displacementFilter:DisplacementMapFilter;
		private var correctionTransform:ColorTransform;
		private var mixLayer:Sprite;
		
		private var mixerWidth:int;
		private var mixerHeight:int;

		private var mixerRect:Rectangle;
		private var origin:Point;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		
		public function SbColormixer() {
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		/**
		 * Used by data-based buttons
		 */
		public function get id() : String
		{
			return _id;
		}

		public function set id(value : String) : void
		{
			_id = value;
		}

		
		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			addEventListener( MouseEvent.MOUSE_DOWN, onThisMouseDown );
			
			mixerWidth = 200;
			mixerHeight = 200;
			
			_displayMap = new BitmapData(mixerWidth,mixerHeight,false,0);
			_displayMap.perlinNoise(32,32,3,123456,false,true,7);
			mapDisplay = new Bitmap(_displayMap);
			addChild(mapDisplay);
			mixerRect = _displayMap.rect;
			origin = new Point();
			
			_displacementMap = new BitmapData(mixerWidth,mixerHeight,false,0);
			_displacementMap.perlinNoise(64,64,1,44243,false,true,3);
			
			_displacementFilter = new DisplacementMapFilter(_displacementMap,origin,1,2 );
			correctionTransform = new ColorTransform(1,1,1,0.0155);
			invalidateLayout();
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			
		}

		private function onThisMouseDown( event:MouseEvent ):void {
			if ( mapDisplay.mouseX > -1 && mapDisplay.mouseX < mixerWidth && mapDisplay.mouseY > -1 && mapDisplay.mouseY < mixerHeight )
			{
				stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
				stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
				_lastMouseX = mapDisplay.mouseX;
				_lastMouseY = mapDisplay.mouseY;
					
			}
			
		}
		
		protected function onStageMouseMove(event:MouseEvent):void
		{
			var dx:Number = mapDisplay.mouseX - _lastMouseX;
			var dy:Number = mapDisplay.mouseY - _lastMouseY;
			
			_displacementFilter.scaleX = dx;
			_displacementFilter.scaleY = dy;
			
			_displayMap.applyFilter(_displayMap, mixerRect, origin,_displacementFilter );
			_displayMap.draw(_displayMap,null,correctionTransform,"add");
			_lastMouseX = mapDisplay.mouseX;
			_lastMouseY = mapDisplay.mouseY;
		}
		
		public function dispose():void {
			
		}

		private function invalidateLayout():void {
			// Update label.
			
		}


		

		override public function get width():Number {
			return 256;
		}

		override public function get height():Number {
			return 256;
		}
	}
}
