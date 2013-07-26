package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.errors.AbstractMethodError;

	public class AbstractBrushShape
	{
		private var _texture : Texture;
		private var _normalSpecularMap : Texture;
		protected var _scaleFactor : Number;
		private var _size : Number;
		private var _id : String;
		protected var _variationFactors:Vector.<Number>;
		protected var _rotationRange:Number;
		protected var _textureSize : Number;
		protected var _YUVWeights:Vector.<Number>;
		private var _context : Context3D;
		
		/**
		 * Creates a new brush texture
		 * @param scaleFactor If a size is set, scaleFactor enlargers the brush texture. This allows a bigger brush area coverage for simulations to operate on
		 */
		public function AbstractBrushShape(context3D : Context3D, id : String, scaleFactor : Number = 1, size:int = 64, cols:int = 1, rows:int = 1)
		{
			_id = id;
			_scaleFactor = scaleFactor;
			_context = context3D;
			this.size = size;
			//_variationFactors = Vector.<Number>([1,1,1,1,Math.atan2(1,1),Math.sqrt(2*64*64)]); //cols,rows,u_step,v_step,rectangle diagonal angle, diagonal length
			_rotationRange = Math.PI;
			_YUVWeights = Vector.<Number>([1,1,1]);
			setVariationFactors(cols,rows);
		}

		protected function setVariationFactors( cols:int, rows:int ):void
		{
			//cols,rows,u_step,v_step,rectangle diagonal angle, diagonal length
			_variationFactors = Vector.<Number>([
				cols,
				rows,
				1 / cols,
				1 / rows,
				Math.atan2(1/rows,1/cols),
				Math.sqrt(Math.pow(size / rows, 2) + Math.pow( size / rows, 2))]); 
			
			_scaleFactor = Math.sqrt(Math.pow( _variationFactors[2],2) +  Math.pow( _variationFactors[3],2));
		}
		
		final public function update() : void
		{
			updateTexture(_texture);
		}

		protected function updateTexture(texture : Texture) : void
		{
			// does nothing by default
		}

		public function get id() : String
		{
			return _id;
		}

		public function get actualSize() : Number
		{
			return _size*_scaleFactor;
		}

		public function get size() : Number
		{
			return _size;
		}

		public function set size(value : Number) : void
		{
			_size = value;
		}

		public function get texture() : Texture
		{
			if (!_texture) initTexture();
			return _texture;
		}

		public function get normalSpecularMap() : Texture
		{
			if (!_normalSpecularMap) initNormalSpecularMap();
			return _normalSpecularMap;
		}

		public function get variationFactors() : Vector.<Number>
		{
			return _variationFactors;
		}

		public function get rotationRange() : Number
		{
			return _rotationRange;
		}

		public function set rotationRange( value:Number ) : void
		{
			_rotationRange = value;
		}
		
		public function getClosestColorMatchYUV( color:Vector.<Number>, targetRect:Rectangle, mismatchProbability:Number = 0, YUVWeights:Vector.<Number> = null ):void
		{
			targetRect.x = targetRect.y = 0;
			targetRect.width = targetRect.height = 1;
		}

		
		private function initTexture() : void
		{
			// I had to replace this since it looks like we are using "actualSize" for two different things
			//_textureSize = TextureUtils.getBestPowerOf2(actualSize);
			_textureSize = size;
			
			_texture = _context.createTexture(_textureSize, _textureSize, Context3DTextureFormat.BGRA, false);
			uploadBrushTexture(_texture);
		}

		private function initNormalSpecularMap() : void
		{
			// I had to replace this since it looks like we are using "actualSize" for two different things
			//_textureSize = TextureUtils.getBestPowerOf2(actualSize);
			_textureSize = size;
			_normalSpecularMap = _context.createTexture(_textureSize, _textureSize, Context3DTextureFormat.BGRA, false);
			uploadNormalSpecularMap(_normalSpecularMap);
		}


		protected function uploadNormalSpecularMap(normalSpecularMap : Texture) : void
		{
		}

		protected function uploadBrushTexture(texture : Texture) : void
		{
			throw new AbstractMethodError();
		}

		public function freeMemory() : void
		{
			if (_texture) {
				_texture.dispose();
				_texture = null;
			}
		}

		protected function uploadMips(size : int, source : BitmapData, texture : Texture) : void
		{
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, false);
			var scaleTransform : Matrix = new Matrix(size / source.width, 0, 0, size / source.width);
			var mipLevel : int = 0;
			var rect : Rectangle = bitmapData.rect;

			while (size > 0) {
				bitmapData.fillRect(rect, 0x000000);
				bitmapData.drawWithQuality(source, scaleTransform, null, "normal", null, true, StageQuality.BEST);
				texture.uploadFromBitmapData(bitmapData, mipLevel);
				scaleTransform.scale(0.5, 0.5);
				mipLevel++;
				size >>= 1;
			}
			bitmapData.dispose();
		}

	}
}
