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

	public class ColorBlender extends Sprite
	{
		private var _id : String;
		
		private var mapDisplay:Bitmap;
		private var _displayMap:BitmapData;
		private var _tempMap:BitmapData;
		private var mapIndex:int;
		private var _displacementMap:BitmapData;
		private var _maskMap:BitmapData;
		private var _turbulenceMap:BitmapData;
		
		
		private var _samplePixel:BitmapData;
		
		private var _displacementFilter:DisplacementMapFilter;
		
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

		private var shp:Shape;
		private var ct:ColorTransform;
		private var ct_shp:ColorTransform;
		
		private var palette:Array;
		private var drawFinger:Sprite;

		private var holder1:Bitmap;
		private var colorInfluence:Number;
		
		public function ColorBlender( palette:Array ) {
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
			fingerSize = 128;
			shp = new Shape();
			
			_displayMap = new TrackedBitmapData(mixerWidth,mixerHeight,true,0);
			_tempMap = new TrackedBitmapData(mixerWidth,mixerHeight,true,0);
			for ( var i:int = 0; i < 12; i++ )
			{
				shp.graphics.beginFill(palette[int(Math.random()*6)],0.5 + Math.random()*0.5);
				var r:Number = 8 + Math.random() * 32;
				shp.graphics.drawCircle(16+r+Math.random()*(mixerWidth-32-r),6+r+Math.random()*(mixerHeight-32-r),r);
			}
			mapIndex = 0;
			_displayMap.draw(shp);
			
			mapDisplay = new Bitmap(_displayMap);
			addChild(mapDisplay);
			
			mixerRect = _displayMap.rect;
			origin = new Point();
			
			drawMatrix = new Matrix();
			
			
			_displacementMap = new TrackedBitmapData(mixerWidth,mixerHeight,false,0);
			
			_displacementFilter = new DisplacementMapFilter(_displacementMap,origin, BitmapDataChannel.BLUE, BitmapDataChannel.GREEN,32,32, DisplacementMapFilterMode.COLOR,0,0 );
			
			addChild( new Bitmap(_displacementMap) ).y = -300;
			
			_maskMap = new TrackedBitmapData(mixerWidth*3,mixerHeight*3,true,0);
			
			shp.graphics.clear();
			shp.graphics.beginFill(0x808080);
			shp.graphics.drawRect(0,0,_maskMap.width,_maskMap.height);
			shp.graphics.drawCircle(_maskMap.width*0.5,_maskMap.height*0.5,fingerSize*0.35);
			shp.graphics.endFill();
			
			
			_maskMap.draw(shp);
			_maskMap.applyFilter( _maskMap, _maskMap.rect, origin, new BlurFilter(20,20,2));
			
			copyRect = _maskMap.rect;
			
			_turbulenceMap = new TrackedBitmapData(mixerWidth*2,mixerHeight*2,false,0);
			_turbulenceMap.noise(Math.random() * 0xffffff,110,146,7,false);
			_turbulenceMap.applyFilter( _turbulenceMap, _turbulenceMap.rect, origin, new BlurFilter(4,4,2));
			
			
			_samplePixel = new TrackedBitmapData(1,1,false,0);
			ct = new ColorTransform(1,1,1,2 / 255);
			ct_shp = new ColorTransform();
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
			_samplePixel.setPixel(0,0,0xffffffff);
			_samplePixel.drawWithQuality( _displayMap, drawMatrix,null,"normal",null,true,StageQuality.HIGH_8X8_LINEAR);
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
				colorInfluence = 1;
				
				shp.graphics.clear();
				shp.graphics.beginFill( sampleColor);
				shp.graphics.drawCircle(0,0,26);
				shp.graphics.endFill();
				
				
			}
			
		}
		
		protected function onStageMouseMove(event:MouseEvent):void
		{
			colorInfluence*=0.8;
			if ( !(mapDisplay.mouseX > -1 && mapDisplay.mouseX < mixerWidth && mapDisplay.mouseY > -1 && mapDisplay.mouseY < mixerHeight)) return;
			
			_displayMap.lock();
			var dx:int = (mapDisplay.mouseX - _lastMouseX) * 3;
			var dy:int = (mapDisplay.mouseY - _lastMouseY) * 3;
			
			_displacementMap.fillRect(_displacementMap.rect,((128 - dx)) | ((128 - dy)<<8));
			
			
			drawMatrix.a=drawMatrix.d = 1;
			
			drawMatrix.tx = -Math.random() * (_turbulenceMap.width - _displacementMap.width);
			drawMatrix.ty = - Math.random() * (_turbulenceMap.height - _displacementMap.height);
			_displacementMap.draw(_turbulenceMap,drawMatrix,null,"overlay");
		
			
			drawMatrix.tx = -_maskMap.width * 0.5 + mapDisplay.mouseX ;
			drawMatrix.ty = -_maskMap.height * 0.5 + mapDisplay.mouseY ;
			_displacementMap.draw(_maskMap,drawMatrix,null,"normal");
			
			if ( colorInfluence > 0.02 )
			{
				
				ct_shp.color = sampleColor;
				ct_shp.alphaOffset = -255* (1 - colorInfluence);
				drawMatrix.tx = mapDisplay.mouseX  ;
				drawMatrix.ty = mapDisplay.mouseY ;
				_displayMap.draw( shp, drawMatrix, ct_shp);
				
			}
			
			_displayMap.applyFilter(_displayMap,mixerRect,origin,_displacementFilter);
			
			//_displayMap.draw(_displayMap,null,ct);
			
			//copyRect.x = _lastMouseX - 64;
			//copyRect.y = _lastMouseY - 64;
			
			//_fingerMap.fillRect( _fingerMap.rect, 0 );
			//_fingerMap.copyPixels(_displayMap, copyRect, origin, _maskMap,origin,false );
			/*
				
		
			_fingerMap.applyFilter(_fingerMap,_fingerMap.rect,origin,_displacementFilter);
			_fingerMap.copyChannel(_maskMap, _fingerMap.rect, origin,8,8 );
			
			drawMatrix.a=drawMatrix.d = 1;
			drawMatrix.tx = mapDisplay.mouseX - 64;
			drawMatrix.ty = mapDisplay.mouseY - 64;
			
			_displayMap.drawWithQuality(drawFinger,drawMatrix,null,"normal",null,true,StageQuality.HIGH);
			*/
			//_displacementMap.fillRect(_displacementMap.rect,((128 - dx)) | ((128 - dy)<<8));
			//mixer.update( mapDisplay.mouseX, mapDisplay.mouseY, dx, dy, 20, 0xff000000 );
			
			
			//copyRect.x =
			//copyRect.y = 
			
			//_displacementMap.copyPixels(_turbulenceMap, copyRect,origin);
			//_displacementMap.draw( _turbulenceMap,drawMatrix,null,"overlay" );
			
			
			//drawMatrix.tx = mapDisplay.mouseX - _maskCenterX ;
			//drawMatrix.ty = mapDisplay.mouseY - _maskCenterY;
			//_displacementMap.draw( _maskMap, drawMatrix );
			
		
			//_displacementFilter.scaleX = 256;
			//_displacementFilter.scaleY = 256;
			//_displayMap.applyFilter(_displayMap, mixerRect, origin,_displacementFilter );
			//_displayMap.draw(_displayMap );
			
			//_displayMap.applyFilter(_displayMap,mixerRect,origin,cmf);
			
			_lastMouseX = mapDisplay.mouseX;
			_lastMouseY = mapDisplay.mouseY;
			
			_displayMap.unlock();
			//mapIndex = 1 - mapIndex;
		}
		
		public function dispose():void {
			
		}

		private function invalidateLayout():void {
			// Update label.
			
		}

		public function get currentColor():int
		{
			return sampleColor;
		}
		
		public function set currentColor(value:int):void
		{
			 sampleColor = value;
		}
		

		override public function get width():Number {
			return 270;
		}

		override public function get height():Number {
			return 190;
		}
	}
}
