package net.psykosoft.psykopaint2.utils.scale
{
	import flash.errors.IllegalOperationError;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Scale3Image extends Sprite	{
		private var _scale3Texture:Scale3Texture;
		
		private var _firstImage:Image;
		private var _secondImage:Image;
		private var _thirdImage:Image;
		private var _width:Number;
		
		public function Scale3Image(scale3Texture:Scale3Texture)
		{
			super();
			this.texture = scale3Texture;
			
			
			
		}
		
		
		public function get texture():Scale3Texture
		{
			return this._scale3Texture;
		}
	
		public function set texture(value:Scale3Texture):void
		{
			trace("[Scale3Image] set texture "+value)
			if(!value)
			{
				throw new IllegalOperationError("Scale3Image textures cannot be null.");
			}
			if(this._scale3Texture == value)
			{
				return;
			}
			this._scale3Texture = value;
			
			_firstImage = new Image(_scale3Texture.first);
			_secondImage= new Image(_scale3Texture.second);
			_thirdImage = new Image(_scale3Texture.third);
			this.addChild(_firstImage);
			this.addChild(_secondImage);
			this.addChild(_thirdImage);
			
			_secondImage.x = _firstImage.width;
			_thirdImage.x = _secondImage.x+_secondImage.width;
			
		}
		
		/*
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			if(!resultRect)
			{
				resultRect = new Rectangle();
			}
			
			
			var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
			var HELPER_MATRIX:Matrix = new Matrix();
			var HELPER_POINT:Point = new Point();
			var hitArea:Rectangle = new Rectangle();
			
			if (targetSpace == this) // optimization
			{
				minX = hitArea.x;
				minY = hitArea.y;
				maxX = hitArea.x + hitArea.width;
				maxY = hitArea.y + hitArea.height;
			}
			else
			{
				this.getTransformationMatrix(targetSpace, HELPER_MATRIX);
				
				MatrixUtil.transformCoords(HELPER_MATRIX, hitArea.x, hitArea.y, HELPER_POINT);
				minX = minX < HELPER_POINT.x ? minX : HELPER_POINT.x;
				maxX = maxX > HELPER_POINT.x ? maxX : HELPER_POINT.x;
				minY = minY < HELPER_POINT.y ? minY : HELPER_POINT.y;
				maxY = maxY > HELPER_POINT.y ? maxY : HELPER_POINT.y;
				
				MatrixUtil.transformCoords(HELPER_MATRIX, hitArea.x, hitArea.y + hitArea.height, HELPER_POINT);
				minX = minX < HELPER_POINT.x ? minX : HELPER_POINT.x;
				maxX = maxX > HELPER_POINT.x ? maxX : HELPER_POINT.x;
				minY = minY < HELPER_POINT.y ? minY : HELPER_POINT.y;
				maxY = maxY > HELPER_POINT.y ? maxY : HELPER_POINT.y;
				
				MatrixUtil.transformCoords(HELPER_MATRIX, hitArea.x + hitArea.width, hitArea.y, HELPER_POINT);
				minX = minX < HELPER_POINT.x ? minX : HELPER_POINT.x;
				maxX = maxX > HELPER_POINT.x ? maxX : HELPER_POINT.x;
				minY = minY < HELPER_POINT.y ? minY : HELPER_POINT.y;
				maxY = maxY > HELPER_POINT.y ? maxY : HELPER_POINT.y;
				
				MatrixUtil.transformCoords(HELPER_MATRIX, hitArea.x + hitArea.width, hitArea.y + hitArea.height, HELPER_POINT);
				minX = minX < HELPER_POINT.x ? minX : HELPER_POINT.x;
				maxX = maxX > HELPER_POINT.x ? maxX : HELPER_POINT.x;
				minY = minY < HELPER_POINT.y ? minY : HELPER_POINT.y;
				maxY = maxY > HELPER_POINT.y ? maxY : HELPER_POINT.y;
			}
			
			resultRect.x = minX;
			resultRect.y = minY;
			resultRect.width  = maxX - minX;
			resultRect.height = maxY - minY;
			
			return resultRect;
		}*/
		
		
		override public function set width (value:Number):void{
			trace("[Scale3Image] width = "+value );
			_width = value;
			this.unflatten();
			_secondImage.x = _firstImage.width;
			_secondImage.width=value - _firstImage.width- _thirdImage.width;
			_thirdImage.x = _secondImage.x+_secondImage.width;
			this.flatten();
			
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		override public function get width ():Number{
			return _width;
		}
		
	}
}