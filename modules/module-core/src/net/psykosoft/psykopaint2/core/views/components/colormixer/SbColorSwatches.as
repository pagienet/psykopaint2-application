package net.psykosoft.psykopaint2.core.views.components.colormixer
{

	import com.quasimondo.color.colorspace.ARGB;
	import com.quasimondo.color.colorspace.HEX;
	import com.quasimondo.color.colorspace.HSL;
	import com.quasimondo.color.colorspace.RGB;
	import com.quasimondo.color.utils.ColorHarmony;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
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
		
		[Embed(source="../../../../../../../../assets/src/images/navigation/colorswatches/colorPalette.png")]
		private var Palette:Class;
		
		[Embed(source="../../../../../../../../assets/src/images/navigation/colorswatches/selectedColor.png")]
		private var ColorSelector:Class;
		
		private var _id : String;
		private var sampleColor:int;
		private var swatchMap:BitmapData;

		private var swatch:Bitmap;
		private var selector:Bitmap;
		
		private var colorHolder:Sprite;
		
		public const palettes:Array = [[0x0b1111,0x05264e,0x00346a,0x01325d,0x01363c,0x016d00],
										[0x452204,0x770c20,0xa81002,0xd84000,0xbe9d02,0xffffff]];
		
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
			
			swatch = new Palette() as Bitmap;
			swatch.smoothing = true;
			swatch.height = 200;
			swatch.scaleX = swatch.scaleY;
			addChild( swatch );
			
			colorHolder = new Sprite();
			
			
			colorHolder.blendMode = "overlay";
			colorHolder.scaleX = colorHolder.scaleY = swatch.scaleX;
			addChild(colorHolder);
			
			selector = new ColorSelector() as Bitmap;
			selector.visible = false;
			selector.scaleX = selector.scaleY = swatch.scaleX;
			addChild(selector);
			
			
			
			swatchMap = swatch.bitmapData;
			sampleColor = -1;
			updateSwatches(0)
			invalidateLayout();
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
		}

		private function onThisMouseDown( event:MouseEvent ):void 
		{
			
			var col:int = (colorHolder.mouseX - 28) / 151;
			var row:int = (colorHolder.mouseY - 25) / 202;
			if ( col > -1 && col < 6 && row > -1 && row < 2 )
			{
				selector.visible = true;
				selector.x = 2+selector.scaleX * col * 151;
				selector.y = 1+selector.scaleY * row * 202;
				sampleColor =  palettes[row][col];
				dispatchEvent( new Event(Event.CHANGE ) );
				setSelection( col + row * 6);
			} else {
				selector.visible = false;
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
		
		public function setSelection( index:int ):void
		{
			if ( index == - 1 )
			{
				selector.visible = false;
			} else {
				if ( index < 6 )
				{
					updateSwatches( index );
				}
				
			}
		}
		
		private function updateSwatches( selectedTopIndex:int = 0):void
		{
			var g:Graphics = colorHolder.graphics;
			g.clear();
			var colorSet1:Vector.<uint> = ColorHarmony.getRange( new HSL(300,55,40),60,6,0,1,0,1);
			for ( var x:int = 0; x < 6; x++ )
			{
				g.beginFill(colorSet1[x] );
				g.drawCircle( 93 + x * 151, 90 + 0 * 202, 67 );
				g.endFill();
				palettes[0][x] = colorSet1[x];
			}
			
			var colorSet2:Vector.<uint> = ColorHarmony.getGradient(ARGB.fromARGBUint(colorSet1[selectedTopIndex]),6);
			for ( var x:int = 0; x < 6; x++ )
			{
				g.beginFill(colorSet2[x] );
				g.drawCircle( 93 + x * 151, 90 + 1 * 202, 67 );
				g.endFill();
				palettes[1][x] = colorSet2[x];
			}
			
		}

		override public function get width():Number {
			return 487;
		}

		override public function get height():Number {
			return 200;
		}
	}
}
