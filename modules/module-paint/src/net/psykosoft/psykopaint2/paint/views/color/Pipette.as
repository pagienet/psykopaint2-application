package net.psykosoft.psykopaint2.paint.views.color
{
	import flash.display.BlendMode;
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
		
		private var bar:Sprite;
		private var _pipetteStartMouseX:Number;
		private var _pipetteStartMouseY:Number;
		
		private var lastPipetteDirectionV:int;
		private var lastPipetteDirectionH:int;
		
		private var incoming_red:Number;
		private var incoming_green:Number;
		private var incoming_blue:Number;
		
		public var pipette_red:Number;
		public var pipette_green:Number;
		public var pipette_blue:Number;
		
		private var _suckTimer:Timer;
		private var ct:ColorTransform;
		private var _selectedColor:uint;
		private var lastActionCharge:Boolean;
		
		public function Pipette()
		{
			super();
			pipette_red = pipette_green= pipette_blue = 0;
			ct = new ColorTransform();
			this.blendMode = BlendMode.LAYER;
			bar = colorbar["bar"];
		}
		
		public function startCharge( incomingColor:uint):void
		{
			visible = true;
			lastActionCharge = false;
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
						lastActionCharge = false; 
						prevFrame();
						dispatchEvent( new Event( "PipetteDischarge" ) );
					} else if ( dy < 0  ){
						lastActionCharge = true;
						if ( currentFrame < totalFrames ) nextFrame();
						var blendFactor:Number =currentFrame -1; 
						pipette_red = (pipette_red * blendFactor + incoming_red) / (blendFactor +1 );
						pipette_green = (pipette_green * blendFactor + incoming_green) / (blendFactor +1 );
						pipette_blue = (pipette_blue * blendFactor + incoming_blue) / (blendFactor +1 );
						dispatchEvent( new Event("PipetteCharge") );
					}
				}
			} else {
			
				direction = dx < 0 ? -1 : ( dx > 0 ? 1 : 0 );
				if ( direction != 0 && lastPipetteDirectionH != direction ) _pipetteStartMouseX =  parent.mouseX;
				lastPipetteDirectionH = direction;
				lastActionCharge = true;
				while (--j > -1 )
				{
					var luma:Number = pipette_red * 0.299 + pipette_green * 0.587 + pipette_blue * 0.114;
					var dr:Number = (pipette_red - luma) * direction * 0.004;
					var dg:Number = (pipette_green - luma) * direction * 0.004;
					var db:Number = (pipette_blue - luma) * direction * 0.004;
					pipette_red += dr;
					pipette_green +=  dg;
					pipette_blue += db;
					if ( pipette_red < 0 ) pipette_red = 0;
					if ( pipette_green < 0 ) pipette_green = 0;
					if ( pipette_blue < 0 ) pipette_blue = 0;
					if ( pipette_red > 255 ) pipette_red = 255;
					if ( pipette_green > 255 ) pipette_green = 255;
					if ( pipette_blue > 255 ) pipette_blue = 255;
					dispatchEvent( new Event("PipetteCharge") );
				}
			}
			
			
			_selectedColor = ct.color = int(pipette_red+0.5) << 16 | int(pipette_green+0.5) << 8 | int(pipette_blue+0.5);
			bar.transform.colorTransform = ct;
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
				dispatchEvent( new Event(Event.COMPLETE) );
			}
		}
		
		public function get currentColor():uint
		{
			return _selectedColor;
		}
		
		public function get isEmpty():Boolean
		{
			return currentFrame == 1;
		}
	}
}