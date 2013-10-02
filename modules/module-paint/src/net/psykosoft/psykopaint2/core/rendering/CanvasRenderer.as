package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display.BitmapData;
	import flash.display.Stage3D;
	import flash.display.TriangleCulling;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasMatrixChanged;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSaveCPUForUISignal;
	import net.psykosoft.psykopaint2.core.signals.RequestResumeCPUUsageForUISignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetCanvasBackgroundSignal;

	public class CanvasRenderer
	{
		[Inject]
		public var canvas : CanvasModel;

		[Inject]
		public var canvasHistory : CanvasHistoryModel;

		[Inject]
		public var stage3D : Stage3D;

		[Inject]
		public var lightingModel : LightingModel;

		[Inject]
		public var requestSaveCPUForUISignal : RequestSaveCPUForUISignal;

		[Inject]
		public var requestResumeCPUUsageForUISignal : RequestResumeCPUUsageForUISignal;

		[Inject]
		public var requestChangeRenderRect : RequestChangeRenderRectSignal;

		[Inject]
		public var notifyCanvasMatrixChanged : NotifyCanvasMatrixChanged;

		[Inject]
		public var requestSetCanvasBackgroundSignal : RequestSetCanvasBackgroundSignal;

		private var _context3D : Context3D;
		private var _lightingRenderer : LightingRenderer;
		private var _background : RefCountedTexture;
		private var _backgroundBaseRect : Rectangle;
		private var _renderRect : Rectangle;

		public function CanvasRenderer()
		{
			_renderRect = new Rectangle(0, 0, CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT);
		}

		public function init(mode : String) : void
		{
			_lightingRenderer.init();
			_lightingRenderer.renderRect = _renderRect;
			_context3D = stage3D.context3D;
			sourceTextureAlpha = mode == PaintMode.PHOTO_MODE? 1 : 0;
			paintAlpha = 1;
		}

		public function dispose() : void
		{
			disposeBackground();
			_lightingRenderer.dispose();
		}

		private function disposeBackground() : void
		{
			if (_background) {
				_background.dispose();
				_background = null;
			}
		}

		[PostConstruct]
		public function postConstruct() : void
		{
			_lightingRenderer = new LightingRenderer(lightingModel, stage3D.context3D);
//			requestSaveCPUForUISignal.add(freezeRendering);
			requestResumeCPUUsageForUISignal.add(resumeRendering);
			requestChangeRenderRect.add(onChangeRenderRect);
			requestSetCanvasBackgroundSignal.add(onSetCanvasBackground);
		}

		private function onSetCanvasBackground(texture : RefCountedTexture, rect : Rectangle) : void
		{
			disposeBackground();
			_background = texture;
			_backgroundBaseRect = rect;
		}

		private function onChangeRenderRect(rect : Rectangle) : void
		{
			_renderRect = rect;
			_lightingRenderer.renderRect = rect;
			updateCanvasMatrix(rect);
		}

		private function updateCanvasMatrix(rect : Rectangle) : void
		{
			var matrix : Matrix = new Matrix();
			matrix.a = rect.width/canvas.width;
			matrix.d = rect.height/canvas.height;
			matrix.tx = rect.x/canvas.width;
			matrix.ty = rect.y/canvas.height;
			notifyCanvasMatrixChanged.dispatch(matrix);
		}

		private function resumeRendering() : void
		{
			_lightingRenderer.freezeRender = false;
		}

		private function freezeRendering() : void
		{
			_lightingRenderer.freezeRender = true;
		}

		public function set sourceTextureAlpha( value:Number ):void
		{
			_lightingRenderer.sourceTextureAlpha  = value;
		}

		public function get sourceTextureAlpha( ):Number
		{
			return _lightingRenderer.sourceTextureAlpha;
		}

		public function set paintAlpha( value:Number ):void
		{
			_lightingRenderer.paintAlpha  = value;
		}

		public function get paintAlpha():Number
		{
			return _lightingRenderer.paintAlpha;
		}

		public function render() : void
		{
			_context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
			_context3D.setCulling(TriangleCulling.NONE);
			_context3D.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.ALWAYS, Context3DStencilAction.SET, Context3DStencilAction.SET, Context3DStencilAction.SET);
			_context3D.setStencilReferenceValue(1);

			if (lightingModel.lightEnabled) {
				_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
				_lightingRenderer.render(canvas);
			}
			else {
				// todo: if rendering source, add the source to be copied
				var sourceRect : Rectangle = new Rectangle(0, 0, canvas.usedTextureWidthRatio, canvas.usedTextureHeightRatio);
				var destRect : Rectangle = new Rectangle(0, 0, 1, 1);
				CopySubTexture.copy(canvas.colorTexture, sourceRect, destRect, _context3D);
			}

			renderBackground();
		}

		private function renderBackground() : void
		{
			if (isBackgroundVisible()) {
				var backgroundRect : Rectangle = createBackgroundRect();
				_context3D.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.EQUAL, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP);
				_context3D.setStencilReferenceValue(0);
				_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
				CopySubTexture.copy(_background.texture, new Rectangle(0, 0, canvas.usedTextureWidthRatio, canvas.usedTextureHeightRatio), backgroundRect, _context3D);
			}
		}

		private function createBackgroundRect() : Rectangle
		{
			var rect : Rectangle = new Rectangle();

			// transformation matrix originalRect -> renderRect
			var scaleX : Number = _renderRect.width / _backgroundBaseRect.width;
			var scaleY : Number = _renderRect.height / _backgroundBaseRect.height;
			var tx : Number = _renderRect.x - scaleX*_backgroundBaseRect.x;
			var ty : Number = _renderRect.y - scaleY*_backgroundBaseRect.y;

			// apply matrix to background rect (= 0, 0, 1, 1)
			rect.width = scaleX;
			rect.height = scaleY;
			rect.x = tx/canvas.width;
			rect.y = ty/canvas.height;

			return rect;
		}

		private function isBackgroundVisible() : Boolean
		{
			return _background && (	_renderRect.left > 0 || _renderRect.right < canvas.width ||
									_renderRect.top > 0 || _renderRect.bottom < canvas.height);
		}

		public function renderToBitmapData() : BitmapData
		{
			var map : BitmapData = new TrackedBitmapData(canvas.width, canvas.height, false, 0);
			var renderRectMemento : Rectangle = _lightingRenderer.renderRect;

			_lightingRenderer.renderRect = new Rectangle(0, 0, canvas.width, canvas.height);
			_context3D = stage3D.context3D;
			_context3D.setRenderToBackBuffer();
			_context3D.clear();

			render();
			_context3D.drawToBitmapData(map);

			_lightingRenderer.renderRect = renderRectMemento;

			return map;
		}
	}
}
