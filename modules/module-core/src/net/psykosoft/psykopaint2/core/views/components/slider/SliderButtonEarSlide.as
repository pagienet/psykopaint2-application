package net.psykosoft.psykopaint2.core.views.components.slider
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	public class SliderButtonEarSlide extends Sprite
	{
		private var _width:int = 150;
		private var _scale:Number = 0.5;
		private var fillMap:BitmapData;
		private var leftBlock:Bitmap;
		private var middleBlock:Bitmap;
		private var rightBlock:Bitmap;
		
		public function SliderButtonEarSlide()
		{
			super();
			fillMap = new SliderButtonSlide() as BitmapData;
			
			leftBlock = new Bitmap( new BitmapData(80,230,true,0),"auto",true );
			leftBlock.bitmapData.draw(fillMap);
			leftBlock.scaleX = leftBlock.scaleY = _scale;
			addChild(leftBlock);
			
			
			middleBlock = new Bitmap(new BitmapData(642 - 160,230,true,0),"auto",true);
			middleBlock.bitmapData.draw(fillMap, new Matrix(1,0,0,1,-80));
			middleBlock.scaleX = middleBlock.scaleY = _scale;
			addChild(middleBlock);
			
			rightBlock = new Bitmap( new BitmapData(80,230,true,0),"auto",true );
			rightBlock.bitmapData.draw(fillMap, new Matrix(1,0,0,1,-642+80));
			rightBlock.scaleX = rightBlock.scaleY = _scale;
			addChild(rightBlock);
			
			
			redraw();
		}
		
		private function redraw():void
		{
			leftBlock.x = -_width*0.5;
			middleBlock.x = -_width*0.5 + 40;
			middleBlock.width = _width-80;
			rightBlock.x =  -_width*0.5 + _width-40;
			
		}
		
		public function set displayWidth( value:Number ):void
		{
			_width = value;
			redraw();
		}

		public function get displayWidth():Number
		{
			return _width;
		}
		
	}
}