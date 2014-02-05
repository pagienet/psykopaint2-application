package net.psykosoft.psykopaint2.core.views.components.colormixer
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import ru.inspirit.utils.FluidSolver;
	
	public class FluidColorMixer extends Sprite
	{
		private const origin:Point = new Point();
		private const identity:Matrix = new Matrix();
		
		public const sw:uint = 270;
		public const sh:uint = 190;
		
		private const DRAW_SCALE:Number = 1;
		
		private const FLUID_WIDTH:uint = 50;
		
		private const isw:Number = 1 / sw;
		private const ish:Number = 1 / sh;
		
		private const aspectRatio:Number = sw * ish;
		private const aspectRatio2:Number = aspectRatio * aspectRatio;
		
		private const fSolver:FluidSolver = new FluidSolver( FLUID_WIDTH, int( FLUID_WIDTH * sh / sw ) );
		
		private var fluid:BitmapData = new BitmapData(fSolver.width - 2, fSolver.height - 2, false, 0);
		private var displayMap:BitmapData = new BitmapData(sw,sh, true, 0);
		
		
		private var fluidBuffer:Vector.<uint> = new Vector.<uint>(fluid.width * fluid.height, true);
		
		private var drawMatrix:Matrix = new Matrix(DRAW_SCALE, 0, 0, DRAW_SCALE, 0, 0);
		private var drawColor:ColorTransform = new ColorTransform(0.1, 0.1, 0.1);
		
		private var prevMouse:Point = new Point();
		private var fluidImage:Bitmap;
		private var fluidMatrix:Matrix = new Matrix(displayMap.width / fluid.width,0,0, displayMap.height / fluid.height);
		private var picker:Shape;
		private var framesUntilStopRendering:int;
		private var cornerRect:Rectangle = new Rectangle(0,0,30,34);
		private var colorInfluence:Number;
		private var _currentColor:uint = 0xff000000;
		
		public function FluidColorMixer()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			fSolver.fadeSpeed = 0;// 0.001;//.007;
			fSolver.deltaT = .7;
			fSolver.viscosity = .0025;
			//fSolver.colorDiffusion = 0.00005;
			
			var dw:Number = sw / fluid.width;
			var dh:Number = sh / fluid.height;
			var s:Number = dw > dh ? dw : dh;
			
			fluidImage = new Bitmap( displayMap, 'never', true );
			fluidImage.width = sw;
			fluidImage.height = sh;
			fluidImage.y  = 0;
			
			addChild(fluidImage);
			
			picker = new Shape();
			picker.graphics.lineStyle(0,0x000000,0.5);
			picker.graphics.drawCircle(0,0,25);
			picker.graphics.lineStyle(0,0xffffff,0.5);
			picker.graphics.drawCircle(0,0,24);
			picker.x = sw*0.5;
			picker.y = sh*0.5;
			//stage.quality = StageQuality.HIGH;
			picker.cacheAsBitmap = true;
			//stage.quality = StageQuality.LOW;
			addChild(picker);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			render(null);
		}
		
		private function restart(e:MouseEvent):void
		{
			fluid.fillRect(fluid.rect, 0x0);
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			if ( mouseX < 0 || mouseY < 0 || mouseX > sw || mouseY > sh ) return;
			if ( cornerRect.contains(mouseX,mouseY))
			{
				fSolver.reset();
				return;
			}
			framesUntilStopRendering = 100;
			colorInfluence = 1;
			picker.x = mouseX;
			picker.y = mouseY;
			addEventListener(Event.ENTER_FRAME, render);
			
			
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
			framesUntilStopRendering = 100;
			colorInfluence *= 0.95;
			handleForce(mouseX, mouseY );
			picker.x = mouseX;
			picker.y = mouseY;
		}
		
		private function handleForce(x:Number, y:Number):void
		{
			var count:int = 16;
			const NormX:Number = x * isw;
			const NormY:Number = y * ish;
			const VelX:Number = (x - prevMouse.x) * isw / count;
			const VelY:Number = (y - prevMouse.y) * ish / count;
			
			for ( var i:int = 0; i < count; i++ )
			{
				addForce(NormX + 0.1 * (Math.random() - Math.random()), NormY + 0.1 * (Math.random() - Math.random()), VelX, VelY, _currentColor,colorInfluence);
			}
			
			prevMouse.x = x;
			prevMouse.y = y;
		}
		
		private function render(e:Event):void 
		{			
			fSolver.update();
			drawFluidBitmap();
			framesUntilStopRendering--;
			if ( framesUntilStopRendering <= 0 ) 
			{
				removeEventListener(Event.ENTER_FRAME, render);
				
			}
		}
		
		public function drawFluidBitmap():void
		{
			const d:int = 0xFF * 1;
			const fw:int = fSolver.width;
			const tw:int = fw - 1;
			const th:int = fSolver.height - 1;
			
			var i:int, j:int, fi:int;
			var index:int = 0;
			
			for(j = 1; j < th; ++j) {
				for(i = 1; i < tw; ++i) {
					fi = int(i + fw * j);
					fluidBuffer[ index++ ] = 0xffffff ^ (((fSolver.r[fi] * d) << 16) | ((fSolver.g[fi] * d) << 8) | (fSolver.b[fi] * d) & 0xffffff);
				}
			}
			fluid.setVector( fluid.rect, fluidBuffer );
			displayMap.lock();
			displayMap.drawWithQuality(fluid,fluidMatrix,null,"normal",null,true,StageQuality.HIGH_16X16_LINEAR);
			displayMap.fillRect(cornerRect,0);
			displayMap.unlock();
		}
		
		
		public function addForce(x:Number, y:Number, dx:Number, dy:Number, color:int = 0xff8000, colorMult:Number = 1):void
		{
			const speed:Number = dx * dx  + dy * dy * aspectRatio2;    // balance the x and y components of speed with the screen aspect ratio
			
			if(speed > 0) {
				if (x < 0) x = 0;
				else if (x > 1) x = 1;
				if (y < 0) y = 0;
				else if (y > 1) y = 1;
				
				var ic:Number = 1-colorMult;
				const velocityMult:Number = 40.0;
				
				const index:int = fSolver.getIndexForNormalizedPosition(x, y);
				
				fSolver.rOld[index]  = fSolver.rOld[index] * ic + ((color >> 16 ) & 0xff) / 0xff * colorMult;
				fSolver.gOld[index]  = fSolver.gOld[index] * ic + ((color >> 8 ) & 0xff) / 0xff * colorMult;
				fSolver.bOld[index]  = fSolver.bOld[index] * ic + (color & 0xff) / 0xff * colorMult;
				
				fSolver.uOld[index] += dx * velocityMult;
				fSolver.vOld[index] += dy * velocityMult;
			}
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