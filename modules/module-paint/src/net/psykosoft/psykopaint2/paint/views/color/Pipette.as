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
		
		private var _pipetteStartMouseX:Number;
		private var _pipetteStartMouseY:Number;
		
		private var lastPipetteDirectionV:int;
		private var lastPipetteDirectionH:int;
		
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
			_pipetteStartMouseX = parent.mouseX;
			_pipetteStartMouseY = parent.mouseY;
			
			lastPipetteDirectionV = 0;
			lastPipetteDirectionH = 0;
			
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
			var dx:int = parent.mouseX - _pipetteStartMouseX;
			var dy:int = parent.mouseY - _pipetteStartMouseY;
			
			var i:int = Math.ceil(Math.sqrt(Math.abs(dy)));
			var j:int = Math.ceil(Math.sqrt(Math.abs(dx)));
			
			if ( j < i )
			{
				var direction:int = dy < 0 ? -1 : ( dy > 0 ? 1 : 0 );
				if ( direction != 0 && lastPipetteDirectionV != direction ) _pipetteStartMouseY =  parent.mouseY;
				lastPipetteDirectionV = direction;
				while (--i > -1 )
				{
					
					if ( dy > 0 && currentFrame > 1)
					{
						prevFrame();
						dispatchEvent( new Event( "PipetteDischarge" ) );
					} else if ( dy < 0  ){
						if ( currentFrame < totalFrames ) nextFrame();
						var blendFactor:Number =currentFrame -1; 
						palette_red = (palette_red * blendFactor + incoming_red) / (blendFactor +1 );
						palette_green = (palette_green * blendFactor + incoming_green) / (blendFactor +1 );
						palette_blue = (palette_blue * blendFactor + incoming_blue) / (blendFactor +1 );
					}
				}
			} else {
			
				direction = dx < 0 ? -1 : ( dx > 0 ? 1 : 0 );
				if ( direction != 0 && lastPipetteDirectionH != direction ) _pipetteStartMouseX =  parent.mouseX;
				lastPipetteDirectionH = direction;
				
				while (--j > -1 )
				{
					var luma:Number = palette_red * 0.299 + palette_green * 0.587 + palette_blue * 0.114;
					var dr:Number = (palette_red - luma) * direction * 0.004;
					var dg:Number = (palette_green - luma) * direction * 0.004;
					var db:Number = (palette_blue - luma) * direction * 0.004;
					palette_red += dr;
					palette_green +=  dg;
					palette_blue += db;
					if ( palette_red < 0 ) palette_red = 0;
					if ( palette_green < 0 ) palette_green = 0;
					if ( palette_blue < 0 ) palette_blue = 0;
					if ( palette_red > 255 ) palette_red = 255;
					if ( palette_green > 255 ) palette_green = 255;
					if ( palette_blue > 255 ) palette_blue = 255;
				}
			}
			
			
			_selectedColor = ct.color = int(palette_red+0.5) << 16 | int(palette_green+0.5) << 8 | int(palette_blue+0.5);
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
				dispatchEvent( new Event(Event.CHANGE) );
			}
		}
		
		public function get currentColor():uint
		{
			return _selectedColor;
		}
	}
}