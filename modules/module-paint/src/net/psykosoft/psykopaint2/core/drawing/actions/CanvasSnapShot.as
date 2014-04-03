package net.psykosoft.psykopaint2.core.drawing.actions
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedRectTexture;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedTexture;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedTexture;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;
	import net.psykosoft.psykopaint2.core.resources.ITextureManager;
	import net.psykosoft.psykopaint2.core.resources.TextureProxy;
	import net.psykosoft.psykopaint2.core.utils.TextureUtils;

	public class CanvasSnapShot
	{
		private var _colorTexture : TrackedRectTexture;
		private var _normalSpecularTexture : TrackedRectTexture;
		private var _context : Context3D;
		private var _canvas : CanvasModel;

		public function CanvasSnapShot(context : Context3D, canvas : CanvasModel)
		{
			_context = context;
			_canvas = canvas;
			_colorTexture = _canvas.createCanvasTexture(true);
			_normalSpecularTexture = _canvas.createCanvasTexture(true);
		}

		public function updateSnapshot() : void
		{
			_context.setStencilActions();
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			saveSnapShotTo(_canvas.colorTexture, _colorTexture);
			saveSnapShotTo(_canvas.normalSpecularMap, _normalSpecularTexture);
		}

		private function saveSnapShotTo(source : TextureBase, target : TrackedRectTexture) : void
		{
			_context.setRenderToTexture(target.texture);
			_context.clear(0.0, 0.0, 0.0, 0.0);
			CopyTexture.copy(source, _context);
		}

		public function dispose() : void
		{
			_colorTexture.dispose();
			_normalSpecularTexture.dispose();
		}

		public function drawColor() : void
		{
			CopyTexture.copy(_colorTexture.texture, _context);
		}

		public function drawNormalsSpecular() : void
		{
			CopyTexture.copy(_normalSpecularTexture.texture, _context);
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

		public function get colorTexture() : TextureBase
		{
			return _colorTexture.texture;
		}

		public function get normalSpecularTexture() : TextureBase
		{
			return _normalSpecularTexture.texture;
		}
	}
}
