package net.psykosoft.psykopaint2.core.views.components.colormixer
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
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

//	import net.psykosoft.psykopaint2.tdsi.ColorMixer;


	public class Colormixer extends Sprite
	{
		private var _id : String;
		
		private var mapDisplay:Bitmap;
		private var _displayMap:BitmapData;
		private var _displacementMap:BitmapData;
		private var _maskMap:BitmapData;
		private var _turbulenceMap:BitmapData;
		
		private var _samplePixel:BitmapData;
		
		private var _displacementFilter:DisplacementMapFilter;
		private var correctionTransform:ColorTransform;
		private var mixLayer:Sprite;
		
		private var mixerWidth:int;
		private var mixerHeight:int;

		private var mixerRect:Rectangle;
		private var origin:Point;
		private var drawMatrix:Matrix;
		private var copyRect:Rectangle;
		
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		private var _maskCenterX:Number;
		private var _maskCenterY:Number;
		private var sampleColor:int;

		private var shp:Shape;
		private var cmf:ColorMatrixFilter;
		private var palettes:Array;
		//private var mixer:ColorMixer;
		
		public function Colormixer( palettes:Array ) {
			super();
			this.palettes = palettes;
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
			
			mixerWidth = 200;
			mixerHeight = 200;
			shp = new Shape();
			
			_displayMap = new TrackedBitmapData(mixerWidth,mixerHeight,true,0);
			for ( var i:int = 0; i < 12; i++ )
			{
				shp.graphics.beginFill(palettes[int(Math.random()*2)][int(Math.random()*6)],0.5 + Math.random()*0.5);
				var r:Number = 8 + Math.random() * 32;
				shp.graphics.drawCircle(16+r+Math.random()*(mixerWidth-32-r),6+r+Math.random()*(mixerHeight-32-r),r);
			}
			_displayMap.draw(shp);
			
			mapDisplay = new Bitmap(_displayMap);
			addChild(mapDisplay);
			mixerRect = _displayMap.rect;
			origin = new Point();
			copyRect = mixerRect.clone();
			drawMatrix = new Matrix();
			
			_displacementMap = new TrackedBitmapData(mixerWidth,mixerHeight,false,0);
			
			_displacementFilter = new DisplacementMapFilter(_displacementMap,origin,1,2,128,128, DisplacementMapFilterMode.COLOR,0,0 );
			
			
			shp.graphics.beginFill(0x808080);
			shp.graphics.drawRect(0,0,32+mixerWidth*2,32+mixerHeight*2);
			shp.graphics.drawCircle(16+mixerWidth,16+mixerHeight,24);
			
			
			_maskMap = new TrackedBitmapData(32+mixerWidth*2,32+mixerHeight*2,true,0);
			_maskMap.draw(shp);
			_maskMap.applyFilter( _maskMap, _maskMap.rect, origin, new BlurFilter(12,12,2));
			
			shp.graphics.clear();
			shp.graphics.beginFill(0x808080);
			shp.graphics.drawRect(0,0,32+mixerWidth*2,32+mixerHeight*2);
			shp.graphics.drawRect(32,32,mixerWidth*2-64,mixerHeight*2-64);
			_maskMap.draw(shp);
			
			_maskCenterX = _maskMap.width * 0.5;
			_maskCenterY = _maskMap.height * 0.5;
			
			
			
			_turbulenceMap = _maskMap.clone();
			_turbulenceMap.noise(Math.random() * 0xffffff,0,128,3,false);
			_turbulenceMap.applyFilter( _turbulenceMap, _turbulenceMap.rect, origin, new BlurFilter(2,2,2));
			
			
			cmf = new ColorMatrixFilter([0.999,0,0,0,0,0,0.999,0,0,0,0,0,0.999,0,0,0,0,1.02,0]);
			
			for ( var i:int = 0; i < 3; i++)
			{
				_displacementFilter.scaleX = 32 * Math.random() - 16;
				_displacementFilter.scaleY = 32 * Math.random() - 16;
				
				copyRect.x = Math.random() * (_turbulenceMap.width - _displacementMap.width);
				copyRect.y = Math.random() * (_turbulenceMap.height - _displacementMap.height);
				_displacementMap.copyPixels(_turbulenceMap, copyRect,origin);
				_displayMap.applyFilter(_displayMap, mixerRect, origin,_displacementFilter );
			}
			
			_samplePixel = new TrackedBitmapData(1,1,false,0);
			//correctionTransform = new ColorTransform(1,1,1,0.05);
			sampleColor = -1;
			
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
			
			_samplePixel.drawWithQuality( _displayMap, drawMatrix,null,"normal",null,true),StageQuality.HIGH_8X8_LINEAR;
			sampleColor = _samplePixel.getPixel32(0,0);
			dispatchEvent( new Event(Event.CHANGE ) );
		}

		private function onThisMouseDown( event:MouseEvent ):void {
			if ( mapDisplay.mouseX > -50 && mapDisplay.mouseX < mixerWidth + 50 && mapDisplay.mouseY > -50 && mapDisplay.mouseY < mixerHeight + 50 )
			{
				stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
				stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
				_lastMouseX = mapDisplay.mouseX;
				_lastMouseY = mapDisplay.mouseY;
				
			//	mixer.update( mapDisplay.mouseX, mapDisplay.mouseY, 0, 0, 0xff000000 );
			}
			
		}
		
		protected function onStageMouseMove(event:MouseEvent):void
		{
			if ( !(mapDisplay.mouseX > -1 && mapDisplay.mouseX < mixerWidth && mapDisplay.mouseY > -1 && mapDisplay.mouseY < mixerHeight)) return;
			
			_displayMap.lock();
			var dx:int = (mapDisplay.mouseX - _lastMouseX);
			var dy:int = (mapDisplay.mouseY - _lastMouseY);
			
			
			//mixer.update( mapDisplay.mouseX, mapDisplay.mouseY, dx, dy, 20, 0xff000000 );
			
			
			copyRect.x = Math.random() * (_turbulenceMap.width - _displacementMap.width);
			copyRect.y = Math.random() * (_turbulenceMap.height - _displacementMap.height);
			
			_displacementMap.copyPixels(_turbulenceMap, copyRect,origin);
			
			drawMatrix.a=drawMatrix.d = 1;
			drawMatrix.tx = mapDisplay.mouseX - _maskCenterX ;
			drawMatrix.ty = mapDisplay.mouseY - _maskCenterY;
			_displacementMap.draw( _maskMap, drawMatrix );
			
			_displacementFilter.scaleX = 2 * dx;
			_displacementFilter.scaleY = 2 * dy;
			_displayMap.applyFilter(_displayMap, mixerRect, origin,_displacementFilter );
			//_displayMap.draw(_displayMap );
			
			//_displayMap.applyFilter(_displayMap,mixerRect,origin,cmf);
			
			_lastMouseX = mapDisplay.mouseX;
			_lastMouseY = mapDisplay.mouseY;
			
			_displayMap.unlock();
		}
		
		public function dispose():void {
			
		}

		private function invalidateLayout():void {
			// Update label.
			
		}

		public function get pickedColor():int
		{
			return sampleColor;
		}
		

		override public function get width():Number {
			return 200;
		}

		override public function get height():Number {
			return 200;
		}
	}
}
