package net.psykosoft.psykopaint2.core.views.components.colormixer
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class Colormixer extends Sprite
	{
		private var _id : String;
		
		private var mapDisplay:Bitmap;
		private var _displayMap:BitmapData;
		private var _drawMap:BitmapData;
		
		
		private var _samplePixel:BitmapData;
		
		
		private var mixLayer:Sprite;
		
		private var mixerWidth:int;
		private var mixerHeight:int;
		
		private var fingerSize:int;
		

		private var mixerRect:Rectangle;
		private var origin:Point;
		private var drawMatrix:Matrix;
		private var copyRect:Rectangle;
		
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		private var _maskCenterX:Number;
		private var _maskCenterY:Number;
		private var sampleColor:int;

		//private var shp:Shape;
		private var ct:ColorTransform;
		private var ct_shp:ColorTransform;
		
		private var palette:Array;
		private var drawFinger:Sprite;

		private var holder1:Bitmap;
		private var colorInfluence:Number;
		private var blurFilter:BlurFilter;
		private var cornerRect:Rectangle = new Rectangle(0,0,30,34);
		private var r:Number;
		private var g:Number;
		private var b:Number;
		
		
		public function Colormixer( palette:Array ) {
			super();
			this.palette = palette;
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
			
			mixerWidth = 270;
			mixerHeight = 190;
			fingerSize = 40;
			origin = new Point();
			
			var shp:Shape = new Shape();
			
			_displayMap = new TrackedBitmapData(mixerWidth,mixerHeight,true,0);
			_drawMap = new TrackedBitmapData(fingerSize,fingerSize,true,0);
			
		
			
			shp.graphics.clear();
			shp.graphics.beginFill(0xffffff);
			shp.graphics.drawCircle(fingerSize*0.5,fingerSize*0.5, fingerSize*0.33);
			shp.graphics.endFill();
			_drawMap.drawWithQuality(shp,null,null,"normal",null,true,StageQuality.HIGH);
			
			blurFilter = new BlurFilter(8,8,2);
			_drawMap.applyFilter(_drawMap,_drawMap.rect,origin,blurFilter);
			
			mapDisplay = new Bitmap(_displayMap);
			addChild(mapDisplay);
			
		
			mixerRect = _displayMap.rect;
			
			drawMatrix = new Matrix();
			
			
			_samplePixel = new TrackedBitmapData(1,1,false,0);
			ct = new ColorTransform();
			ct_shp = new ColorTransform();
			sampleColor = -1;
			r = g = b = 0;
		//	mixer = new ColorMixer( _displayMap );
			invalidateLayout();
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			
			if ( !(mapDisplay.mouseX > -1 && mapDisplay.mouseX < mixerWidth && mapDisplay.mouseY > -1 && mapDisplay.mouseY < mixerHeight)) return;
			
			drawMatrix.a = drawMatrix.d = 0.1;
			drawMatrix.tx = -mapDisplay.mouseX * 0.1;
			drawMatrix.ty = -mapDisplay.mouseY * 0.1;
			_samplePixel.setPixel(0,0,0xffffffff);
			_samplePixel.drawWithQuality( _displayMap, drawMatrix,null,"normal",null,true,StageQuality.HIGH_8X8_LINEAR);
			sampleColor = _samplePixel.getPixel32(0,0);
			dispatchEvent( new Event(Event.CHANGE ) );
		}

		private function onThisMouseDown( event:MouseEvent ):void {
			if ( cornerRect.contains( mapDisplay.mouseX, mapDisplay.mouseY))
			{
				_displayMap.fillRect(mixerRect,0);
			}
			if ( mapDisplay.mouseX > -50 && mapDisplay.mouseX < mixerWidth + 50 && mapDisplay.mouseY > -50 && mapDisplay.mouseY < mixerHeight + 50 )
			{
				stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
				stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
				_lastMouseX = mapDisplay.mouseX;
				_lastMouseY = mapDisplay.mouseY;
				colorInfluence = 1;
			}
			
		}
		
		public function addColorSpot( x:int, y:int, color:uint, radius:Number ):void
		{
			_displayMap.lock();
			
			ct_shp.color = color;
			ct_shp.alphaMultiplier = 0.2;
			drawMatrix.a = drawMatrix.d = radius / fingerSize; 
			drawMatrix.tx = x - radius * 0.5;
			drawMatrix.ty = y - radius * 0.5;
			
			_displayMap.drawWithQuality(_drawMap,drawMatrix,ct_shp,"normal",null,true,StageQuality.HIGH);
			_displayMap.unlock();
		}
			
			
		
		protected function onStageMouseMove(event:MouseEvent):void
		{
			
			if ( !(mapDisplay.mouseX > -1 && mapDisplay.mouseX < mixerWidth && mapDisplay.mouseY > -1 && mapDisplay.mouseY < mixerHeight)) return;
			_displayMap.lock();
			var dx:int = (mapDisplay.mouseX - _lastMouseX) * 0.3;
			var dy:int = (mapDisplay.mouseY - _lastMouseY) * 0.3;
			
			
				
			drawMatrix.a = drawMatrix.d = 0.1;
			drawMatrix.tx = -mapDisplay.mouseX * 0.1;
			drawMatrix.ty = -mapDisplay.mouseY * 0.1;
			_samplePixel.setPixel(0,0,0xffffffff);
			_samplePixel.drawWithQuality( _displayMap, drawMatrix,null,"normal",null,true,StageQuality.HIGH_8X8_LINEAR);
			var c:int = _samplePixel.getPixel(0,0);
			//colorInfluence = 0.5;
			r = r * ( 1-colorInfluence) + ((c >> 16) & 0xff) * colorInfluence;
			g = g * ( 1-colorInfluence) + ((c >> 8) & 0xff) * colorInfluence;
			b = b * ( 1-colorInfluence) + (c & 0xff) * colorInfluence;
			
			
			ct_shp.color = int(r+0.5) << 16 |  int(g+0.5) << 8 |  int(b+0.5);
			ct_shp.alphaMultiplier = 0.25 + colorInfluence * 0.4;
			drawMatrix.a = drawMatrix.d = 1; 
			drawMatrix.tx = mapDisplay.mouseX - fingerSize * 0.5;
			drawMatrix.ty = mapDisplay.mouseY - fingerSize * 0.5;
			
			_displayMap.drawWithQuality(_drawMap,drawMatrix,ct_shp,"normal",null,true,StageQuality.HIGH);
			
			
			
			_lastMouseX = mapDisplay.mouseX;
			_lastMouseY = mapDisplay.mouseY;
			if (colorInfluence > 0.5 ) colorInfluence *=0.99;
			
			_displayMap.unlock();
			
		}
		
		public function dispose():void {
			removeEventListener( MouseEvent.MOUSE_DOWN, onThisMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			_displayMap.dispose();
			_samplePixel.dispose();
			_drawMap.dispose();
			drawMatrix = null;
		}

		private function invalidateLayout():void {
			// Update label.
			
		}
		
		public function set mixEnabled( value:Boolean ):void
		{
			if ( value )
			{
				addEventListener( MouseEvent.MOUSE_DOWN, onThisMouseDown );
			} else {
				removeEventListener( MouseEvent.MOUSE_DOWN, onThisMouseDown );
				stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
				
			}
		}

		public function get currentColor():int
		{
			return sampleColor;
		}
		
		public function set currentColor(value:int):void
		{
			 sampleColor = value;
		}
		
		public function getColorAtMouse():int
		{
			drawMatrix.a = drawMatrix.d = 0.1;
			drawMatrix.tx = -mapDisplay.mouseX * 0.1;
			drawMatrix.ty = -mapDisplay.mouseY * 0.1;
			_samplePixel.setPixel(0,0,0xffffffff);
			_samplePixel.drawWithQuality( _displayMap, drawMatrix,null,"normal",null,true,StageQuality.HIGH_8X8_LINEAR);
			return _samplePixel.getPixel32(0,0);
		}

		override public function get width():Number {
			return 270;
		}

		override public function get height():Number {
			return 190;
		}
	}
}
