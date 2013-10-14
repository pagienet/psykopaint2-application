package net.psykosoft.psykopaint2.paint.views.color
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Timer;
	
	public class Pipette extends MovieClip
	{
		public var colorbar:Sprite;
		
		private var _pipetteStartMouseY:Number;
		private var lastPipetteDirection:int;
		
		private var incoming_red:Number;
		private var incoming_green:Number;
		private var incoming_blue:Number;
		
		private var palette_red:Number;
		private var palette_green:Number;
		private var palette_blue:Number;
		
		private var _suckTimer:Timer;
		private var ct:ColorTransform;
		private var _selectedColor:uint;
		
		
		public function Pipette()
		{
			super();
			palette_red = palette_green= palette_blue = 0;
			ct = new ColorTransform();
		}
		
		public function startCharge( incomingColor:uint):void
		{
			visible = true;
			_pipetteStartMouseY = parent.mouseY;
			lastPipetteDirection = 0;
			
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
			
		}
		
		protected function suckInPipette(event:TimerEvent):void
		{
			var dy:int = parent.mouseY - _pipetteStartMouseY;
			var i:int = Math.ceil(Math.sqrt(Math.abs(dy)));
			var direction:int = dy < 0 ? -1 : ( dy > 0 ? 1 : 0 );
			if ( direction != 0 && lastPipetteDirection != direction ) _pipetteStartMouseY =  parent.mouseY;
			lastPipetteDirection = direction;
			
			while (--i > -1 )
			{
				
				if ( dy > 0 && currentFrame > 1)
					prevFrame()
				else if ( dy < 0  ){
					if ( currentFrame < totalFrames ) nextFrame();
					var blendFactor:Number =currentFrame -1; 
					palette_red = (palette_red * blendFactor + incoming_red) / (blendFactor +1 );
					palette_green = (palette_green * blendFactor + incoming_green) / (blendFactor +1 );
					palette_blue = (palette_blue * blendFactor + incoming_blue) / (blendFactor +1 );
				}
				
				
				
			}
			ct.color = int(palette_red+0.5) << 16 | int(palette_green+0.5) << 8 | int(palette_blue+0.5);
			colorbar.transform.colorTransform = ct;
		}		
		
		public function endPipetteCharge(event:MouseEvent = null):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, endPipetteCharge );
			if ( visible )
			{
				visible = false;
				stop();
				_suckTimer.removeEventListener(TimerEvent.TIMER, suckInPipette );
				_suckTimer.stop();
				_selectedColor = ct.color;
				dispatchEvent( new Event(Event.CHANGE) );
			}
		}
		
		public function get currentColor():uint
		{
			return _selectedColor;
		}
	}
}