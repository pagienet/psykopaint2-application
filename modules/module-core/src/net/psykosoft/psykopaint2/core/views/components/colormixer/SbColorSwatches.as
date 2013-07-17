package net.psykosoft.psykopaint2.core.views.components.colormixer
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	

	public class SbColorSwatches extends Sprite
	{
		
		[Embed(source="../../../../../../../../assets/src/images/navigation/colorswatches/DummyPaintbox.png")]
		private var DummyAsset:Class;
		
		private var _id : String;
		private var sampleColor:int;
		private var swatchMap:BitmapData;

		private var swatch:Bitmap;
		
		public function SbColorSwatches() {
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
			
			swatch = new DummyAsset() as Bitmap;
			addChild( swatch );
			
			swatchMap = swatch.bitmapData;
			sampleColor = -1;
			
			invalidateLayout();
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			
			
		}

		private function onThisMouseDown( event:MouseEvent ):void {
			
			if ( swatch.hitTestPoint( stage.mouseX, stage.mouseY ))
			{
				sampleColor = swatchMap.getPixel32(swatch.mouseX, swatch.mouseY);
				dispatchEvent( new Event(Event.CHANGE ) );
			}
		}
		
		protected function onStageMouseMove(event:MouseEvent):void
		{
			
		}
		
		public function dispose():void {
			
		}

		private function invalidateLayout():void {
			// Update label.
			
		}

		public function get pickedColor():int
		{
			return sampleColor;
		}
		

		override public function get width():Number {
			return 487;
		}

		override public function get height():Number {
			return 200;
		}
	}
}
