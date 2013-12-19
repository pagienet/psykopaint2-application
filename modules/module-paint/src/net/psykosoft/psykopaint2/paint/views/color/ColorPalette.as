package net.psykosoft.psykopaint2.paint.views.color
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Timer;
	
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
		//public var pipette:Pipette;
		/*
		public const palettes:Array = [[0x0b0b0b,0x062750,0x04396c,0x01315a,0x00353b,0x026d01,
										0x452204,0x7a1023,0xa91606,0xd94300,0xbd9c01,0xdedddb]];
		*/
		private var palettes:Array;
		private var swatches:Vector.<Sprite>;
		private var selectedPaletteIndex:int;
		private var _selectedColor:uint;
		private var _currentIndex:int;
		private var _stage:Stage;
		
		
		
		
		
		public function ColorPalette( )
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		// TODO: review disposal of view
		
		private function onAddedToStage( event:Event ):void {
			_stage = stage;
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
		
		}
		
		public function setPalettes( palettes:Array ):void
		{
			this.palettes = palettes;
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
		
		public function changeSelectedColor( ct:ColorTransform):void
		{
			if ( _currentIndex != -1 )
			{
				swatches[_currentIndex].transform.colorTransform = ct;
				palettes[selectedPaletteIndex][_currentIndex] = ct.color;
			}
		}
		
		public function get selectedColor():uint
		{
			return _selectedColor;
		}
		
		public function set selectedColor(value:uint):void
		{
			if ( _currentIndex != -1 )
			{
				var ct:ColorTransform = new ColorTransform();
				ct.color = value;
				swatches[_currentIndex].transform.colorTransform = ct;
				palettes[selectedPaletteIndex][_currentIndex] = swatches[_currentIndex].transform.colorTransform.color;
			}
		}
		
		public function get currentPalette():Array
		{
			return palettes[selectedPaletteIndex];
		}
		
		public function getSwatchUnderMouse():Sprite
		{
			for ( var i:int = 0; i < swatches.length; i++ )
			{
				if ( swatches[i].hitTestPoint(stage.mouseX,stage.mouseY,true ) )
				{
					
					//pipette.colorbar.transform.colorTransform = swatches[i].transform.colorTransform;
					//var incomingColor:int= palettes[selectedPaletteIndex][i]
					return swatches[i];
				}
			}
			return null;
		}
		
		public function getSelectedSwatch():Sprite
		{
			return _currentIndex > -1 ?  swatches[_currentIndex] : null;
		}
		
	}
}