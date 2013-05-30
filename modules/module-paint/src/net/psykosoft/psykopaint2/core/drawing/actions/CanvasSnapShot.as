package net.psykosoft.psykopaint2.core.drawing.actions
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;
	import net.psykosoft.psykopaint2.core.resources.ITextureManager;
	import net.psykosoft.psykopaint2.core.resources.TextureProxy;
	import net.psykosoft.psykopaint2.core.utils.TextureUtils;

	public class CanvasSnapShot
	{
		private var _canvasBounds : Rectangle;
		private var _trimmedBounds : Rectangle;
		private var _colorTexture : TextureProxy;
		private var _heightSpecularTexture : TextureProxy;
		private var _textureManager : ITextureManager;
		private var _context : Context3D;
		private var _canvas : CanvasModel;

		public function CanvasSnapShot(context : Context3D, canvas : CanvasModel, textureManager : ITextureManager, saveNormals : Boolean, bounds : Rectangle = null)
		{
			_textureManager = textureManager;
			_context = context;
			_canvas = canvas;
			_canvasBounds = bounds || new Rectangle(0, 0, canvas.usedTextureWidthRatio, canvas.usedTextureHeightRatio);
			_trimmedBounds = new Rectangle();
			_colorTexture = createSnapFrom(canvas.colorTexture);
			if (saveNormals) _heightSpecularTexture = createSnapFrom(canvas.heightSpecularMap);
		}

		private function createSnapFrom(source : TextureBase) : TextureProxy
		{
			// dimensions in pixels
			var pixelWidth : Number = _canvasBounds.width * _canvas.textureWidth;
			var pixelHeight : Number = _canvasBounds.height * _canvas.textureHeight;
			var texWidth : Number = TextureUtils.getBestPowerOf2(pixelWidth);
			var texHeight : Number = TextureUtils.getBestPowerOf2(pixelHeight);
			var texture : TextureProxy = createTextureProxy(texWidth, texHeight);

			_context.setRenderToTexture(texture.texture);
			_context.clear(0.0, 0.0, 0.0, 0.0);
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

			// dimensions relative to texture
			_trimmedBounds.width = pixelWidth / texWidth;
			_trimmedBounds.height = pixelHeight / texHeight;

			CopySubTexture.copy(source, _canvasBounds, _trimmedBounds, _context);

			return texture;
		}

		public function trim(bounds : Rectangle) : void
		{
			_canvasBounds.copyFrom(bounds);
			var colorTexture : TextureProxy = createSnapFrom(_colorTexture.texture);
			_colorTexture.dispose();
			_colorTexture = colorTexture;

			if (_heightSpecularTexture) {
				var heightTexture : TextureProxy = createSnapFrom(_heightSpecularTexture.texture);
				_heightSpecularTexture.dispose();
				_heightSpecularTexture = heightTexture;
			}
		}

		private function createTextureProxy(texWidth : Number, texHeight : Number) : TextureProxy
		{
			return new TextureProxy(texWidth, texHeight, Context3DTextureFormat.BGRA, true, _textureManager);
		}

		public function dispose() : uint
		{
			var freedBytes:uint = 0;
			if (_colorTexture){
				freedBytes += _colorTexture.size;
				_colorTexture.dispose();
			}
			if (_heightSpecularTexture) {
				freedBytes += _heightSpecularTexture.size;
				_heightSpecularTexture.dispose();
			}
			return freedBytes;
		}

		public function get canvasBounds() : Rectangle
		{
			return _canvasBounds;
		}

		public function get colorTexture() : Texture
		{
			return Texture(_colorTexture.texture);
		}

		public function get heightSpecularTexture() : Texture
		{
			return Texture(_heightSpecularTexture.texture);
		}

		public function drawColor() : void
		{
			CopySubTexture.copy(_colorTexture.texture, _trimmedBounds, _canvasBounds, _context);
		}

		public function drawNormalsSpecular() : void
		{
			CopySubTexture.copy(_heightSpecularTexture.texture, _trimmedBounds, _canvasBounds, _context);
		}
	}
}
