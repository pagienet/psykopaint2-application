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
		private var _colorTexture : Texture;
		private var _normalSpecularTexture : Texture;
		private var _context : Context3D;
		private var _canvas : CanvasModel;

		public function CanvasSnapShot(context : Context3D, canvas : CanvasModel)
		{
			_context = context;
			_canvas = canvas;
			_colorTexture = _context.createTexture(_canvas.textureWidth, _canvas.textureHeight, Context3DTextureFormat.BGRA, true, 0);
			_normalSpecularTexture = _context.createTexture(_canvas.textureWidth, _canvas.textureHeight, Context3DTextureFormat.BGRA, true, 0);
		}

		public function updateSnapshot() : void
		{
			saveSnapShotTo(_canvas.colorTexture, _colorTexture);
			saveSnapShotTo(_canvas.normalSpecularMap, _normalSpecularTexture);
		}

		private function saveSnapShotTo(source : TextureBase, target : TextureBase) : void
		{
			_context.setRenderToTexture(target);
			_context.clear(0.0, 0.0, 0.0, 0.0);
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopyTexture.copy(source, _context, _canvas.usedTextureWidthRatio, _canvas.usedTextureHeightRatio);
		}

		public function dispose() : void
		{
			_colorTexture.dispose();
			_normalSpecularTexture.dispose();
		}

		public function drawColor() : void
		{
			CopyTexture.copy(_colorTexture, _context, _canvas.usedTextureWidthRatio, _canvas.usedTextureHeightRatio);
		}

		public function drawNormalsSpecular() : void
		{
			CopyTexture.copy(_normalSpecularTexture, _context, _canvas.usedTextureWidthRatio, _canvas.usedTextureHeightRatio);
		}

		public function exchangeWithCanvas(canvas : CanvasModel) : void
		{
			canvas.swapColorLayer();	// move current state to back buffer (not allowed to directly set color layer
			_colorTexture = canvas.swapFullSized(_colorTexture);	// swap with back buffer
			canvas.swapColorLayer();

			canvas.swapNormalSpecularLayer();	// move current state to back buffer (not allowed to directly set color layer
			_normalSpecularTexture = canvas.swapFullSized(_normalSpecularTexture);	// swap with back buffer
			canvas.swapNormalSpecularLayer();
		}
	}
}
