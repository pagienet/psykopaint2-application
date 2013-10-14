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
		public var pipette:Pipette;
		
		public const palettes:Array = [[0x000000,0x062750,0x04396c,0x01315a,0x00353b,0x026d01,
										0x452204,0x7a1023,0xa91606,0xd94300,0xbd9c01,0xdedddb]];
		
		private var swatches:Vector.<Sprite>;
		private var selectedPaletteIndex:int;
		private var _selectedColor:uint;
		private var _currentIndex:int;
		private var _stage:Stage;
		private var _pipetteStartMouseY:Number;
		private var _suckTimer:Timer;
		private var palette_red:Number;
		private var palette_green:Number;
		private var palette_blue:Number;
		private var incoming_red:Number;
		private var incoming_green:Number;
		private var incoming_blue:Number;
		private var ct:ColorTransform;
		private var lastPipetteDirection:int;
		
		public function ColorPalette()
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
			_currentIndex = -1;
			showPalette(0);
			selectedIndex = 0;
			palette_red = palette_green= palette_blue = 0;
			ct = new ColorTransform();
			pipette = new Pipette();
			addChild(pipette);
				
			pipette.gotoAndStop(1);
			pipette.visible = false;
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
			_pipetteStartMouseY = mouseY;
			lastPipetteDirection = 0;
			for ( var i:int = 0; i < swatches.length; i++ )
			{
				if ( swatches[i].hitTestPoint(stage.mouseX,stage.mouseY,true ) )
				{
					pipette.x = swatches[i].x;
					pipette.y = swatches[i].y - 32;
					
					pipette.visible = true;
					//
					//pipette.colorbar.transform.colorTransform = swatches[i].transform.colorTransform;
					var incomingColor:int= palettes[selectedPaletteIndex][i]
					incoming_red = (incomingColor >> 16) & 0xff;
					incoming_green = (incomingColor >> 8) & 0xff;
					incoming_blue = incomingColor & 0xff;
					
					if ( _suckTimer == null )
					{
						_suckTimer = new Timer(60);
					}
					_suckTimer.addEventListener(TimerEvent.TIMER, suckInPipette );
					_suckTimer.start();
					stage.addEventListener(MouseEvent.MOUSE_UP, endPipetteCharge );
					
					break;
				}
			}
			
		}
		
		protected function suckInPipette(event:TimerEvent):void
		{
			var dy:int = mouseY - _pipetteStartMouseY;
			var i:int = Math.ceil(Math.sqrt(Math.abs(dy)));
			var direction:int = dy < 0 ? -1 : ( dy > 0 ? 1 : 0 );
			if ( direction != 0 && lastPipetteDirection != direction ) _pipetteStartMouseY = mouseY;
			lastPipetteDirection = direction;
			
			while (--i > -1 )
			{
					
				if ( dy > 0 && pipette.currentFrame > 1)
					pipette.prevFrame()
				else if ( dy < 0  ){
					if ( pipette.currentFrame < pipette.totalFrames ) pipette.nextFrame();
					var blendFactor:Number = pipette.currentFrame -1; 
					palette_red = (palette_red * blendFactor + incoming_red) / (blendFactor +1 );
					palette_green = (palette_green * blendFactor + incoming_green) / (blendFactor +1 );
					palette_blue = (palette_blue * blendFactor + incoming_blue) / (blendFactor +1 );
				}
				
				
				
			}
			ct.color = int(palette_red+0.5) << 16 | int(palette_green+0.5) << 8 | int(palette_blue+0.5);
			pipette.colorbar.transform.colorTransform = ct;
		}		
		
		public function endPipetteCharge(event:MouseEvent = null):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, endPipetteCharge );
			if ( pipette.visible )
			{
				pipette.visible = false;
				pipette.stop();
				_suckTimer.removeEventListener(TimerEvent.TIMER, suckInPipette );
				_suckTimer.stop();
				_selectedColor = ct.color;
				dispatchEvent( new Event(Event.CHANGE) );
			}
		}
	}
}