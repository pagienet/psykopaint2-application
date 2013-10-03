package net.psykosoft.psykopaint2.paint.views.color
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	public class ColorPalette extends Sprite
	{
		public var paletteSelector:Sprite;
		public var colorOverlay0:Sprite;
		public var colorOverlay1:Sprite;
		public var colorOverlay2:Sprite;
		public var colorOverlay3:Sprite;
		public var colorOverlay4:Sprite;
		public var colorOverlay5:Sprite;
		public var colorOverlay6:Sprite;
		public var colorOverlay7:Sprite;
		public var colorOverlay8:Sprite;
		public var colorOverlay9:Sprite;
		public var colorOverlay10:Sprite;
		public var colorOverlay11:Sprite;
		public var pipette:MovieClip;
		
		public const palettes:Array = [[0x000000,0x062750,0x04396c,0x01315a,0x00353b,0x026d01,
										0x452204,0x7a1023,0xa91606,0xd94300,0xbd9c01,0xdedddb]];
		
		private var swatches:Vector.<Sprite>;
		private var selectedPaletteIndex:int;
		private var _selectedColor:uint;
		private var _currentIndex:int;
		
		public function ColorPalette()
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			swatches = Vector.<Sprite>([colorOverlay0,colorOverlay1,colorOverlay2,colorOverlay3,colorOverlay4,colorOverlay5,
										colorOverlay6,colorOverlay7,colorOverlay8,colorOverlay9,colorOverlay10,colorOverlay11
			]);
			
			for ( var i:int = 0; i < swatches.length; i++ )
			{
				swatches[i].addEventListener(MouseEvent.CLICK, onSwatchClicked );
			}
			
			paletteSelector.visible = false;
			paletteSelector.mouseEnabled = false;
			_currentIndex = -1;
			showPalette(0);
			selectedIndex = 0;
		}
		
		private function showPalette( index:int ):void
		{
			selectedPaletteIndex = index;
			for ( var i:int = 0; i < 12; i++ )
			{
				var t:ColorTransform = swatches[i].transform.colorTransform; 
				t.color = 0xff000000 | palettes[index][i];
				swatches[i].transform.colorTransform = t;
			}
		}
		
		private function onSwatchClicked( event:Event ):void
		{
			var swatch:Sprite = event.target as Sprite;
			selectedIndex = swatches.indexOf( swatch );
		}
		
		public function set selectedIndex(index:int):void
		{
			if ( index > -1 )
			{
				if ( _currentIndex != index )
				{
					paletteSelector.visible = true;
					paletteSelector.x = swatches[index].x;
					paletteSelector.y = swatches[index].y+2;
					_selectedColor = palettes[selectedPaletteIndex][index];
					dispatchEvent( new Event(Event.CHANGE) );
				}
			} else {
				paletteSelector.visible = false;
			}
			_currentIndex = index;
		}
		
		public function get selectedColor():uint
		{
			return _selectedColor;
		}
		
		public function get currentPalette():Array
		{
			return palettes[selectedPaletteIndex];
		}
		
		public function attemptPipetteCharge():void
		{
			if ( mouseY < -100 || mouseX < -225 || mouseX > 240 ) return;
			
			pipette.x = mouseX;
			pipette.y = mouseY;
			
			pipette.visible = true;
			pipette.gotoAndPlay(1);
		}
		
		
		public function endPipetteCharge():void
		{
			pipette.visible = false;
			pipette.stop();
		}
	}
}