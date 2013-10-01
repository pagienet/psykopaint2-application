package net.psykosoft.psykopaint2.core.views.components.colormixer
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.tdsi.ColorMixer;
	
	
	public class ColorMixerTDSI extends Sprite
	{
		private const origin:Point = new Point();
		private const identity:Matrix = new Matrix();
		
		public const sw:uint = 270;
		public const sh:uint = 190;
		
		private var mixer:ColorMixer;
		private var displayMap:BitmapData;
		private var fluidImage:Bitmap;
		private var picker:Shape;
		
		private var prevMouse:Point = new Point();
		
		private var cornerRect:Rectangle = new Rectangle(0,0,30,34);
		private var colorInfluence:Number;
		private var _currentColor:uint = 0xff000000;
		
		public function ColorMixerTDSI()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			displayMap = new BitmapData(sw,sh, true, 0);
			displayMap.fillRect(new Rectangle(32,32,sw-64,sh-64),0xff000000);
			fluidImage = new Bitmap( displayMap, 'never', true );
			addChild(fluidImage);
			
			mixer = new ColorMixer(displayMap);
			
			picker = new Shape();
			picker.graphics.lineStyle(0,0x000000,0.5);
			picker.graphics.drawCircle(0,0,25);
			picker.graphics.lineStyle(0,0xffffff,0.5);
			picker.graphics.drawCircle(0,0,24);
			picker.x = sw*0.5;
			picker.y = sh*0.5;
			stage.quality = StageQuality.HIGH;
			picker.cacheAsBitmap = true;
			stage.quality = StageQuality.LOW;
			addChild(picker);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			//render(null);
		}
		
		private function restart():void
		{
			displayMap.fillRect(displayMap.rect, 0x0);
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			if ( mouseX < 0 || mouseY < 0 || mouseX > sw || mouseY > sh ) return;
			if ( cornerRect.contains(mouseX,mouseY))
			{
				restart();
				return;
			}
			
			colorInfluence = 1;
			picker.x = mouseX;
			picker.y = mouseY;
			//addEventListener(Event.ENTER_FRAME, render);
			
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			_currentColor = displayMap.getPixel(picker.x,picker.y)  ^ 0xffffff;
			dispatchEvent( new Event(Event.CHANGE));
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			colorInfluence *= 0.95;
			handleForce(mouseX, mouseY );
			picker.x = mouseX;
			picker.y = mouseY;
		}
		
		private function handleForce(x:Number, y:Number):void
		{
			var count:int = 16;
			
			const VelX:Number = (x - prevMouse.x) ;
			const VelY:Number = (y - prevMouse.y);
			if ( VelX != 0 || VelY != 0 )
				mixer.update(prevMouse.x, prevMouse.y, VelX, VelY, 50,_currentColor, colorInfluence );
				
			
			prevMouse.x = x;
			prevMouse.y = y;
		}
		
		
		public function set currentColor( color:uint ):void
		{
			_currentColor = color ^ 0xffffff;
		}
		
		public function get currentColor( ):uint
		{
			return _currentColor  ^ 0xffffff;
		}
	}
}