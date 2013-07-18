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
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasMatrixChanged;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselRectInfoSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselRectInfoSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFreezeRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestResumeRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSetCanvasBackgroundSignal;

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
		public var requestFreezeRendering : RequestFreezeRenderingSignal;

		[Inject]
		public var requestResumeRendering : RequestResumeRenderingSignal;

		[Inject]
		public var requestChangeRenderRect : RequestChangeRenderRectSignal;

		[Inject]
		public var requestSetCanvasBackgroundSignal:RequestSetCanvasBackgroundSignal;

		[Inject]
		public var notifyEaselRectInfoSignal:NotifyEaselRectInfoSignal;

		[Inject]
		public var requestEaselRectInfoSignal:RequestEaselRectInfoSignal;

		[Inject]
		public var notifyCanvasMatrixChanged : NotifyCanvasMatrixChanged;

		private var _paintModule : PaintModule;
		private var _context3D : Context3D;
		private var _lightingRenderer : LightingRenderer;
		private var _background : RefCountedTexture;
		private var _backgroundBaseRect : Rectangle;

		public function CanvasRenderer()
		{

		}

		public function disposeBackground() : void
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
			requestFreezeRendering.add(freezeRendering);
			requestResumeRendering.add(resumeRendering);
			requestChangeRenderRect.add(onChangeRenderRect);
			requestSetCanvasBackgroundSignal.add(onSetBackgroundSignal);
		}

		private function onSetBackgroundSignal(texture : RefCountedTexture) : void
		{
			disposeBackground();
			notifyEaselRectInfoSignal.addOnce(onEaselRectInfo);
			requestEaselRectInfoSignal.dispatch();
			_background = texture;
		}

		private function onEaselRectInfo(rect : Rectangle) : void
		{
			_backgroundBaseRect = rect.clone();

			if( CoreSettings.RUNNING_ON_RETINA_DISPLAY ) {
				// X and Y don't seem to make sense here
				_backgroundBaseRect.x *= CoreSettings.GLOBAL_SCALING;
				_backgroundBaseRect.y *= CoreSettings.GLOBAL_SCALING;
				_backgroundBaseRect.width *= CoreSettings.GLOBAL_SCALING;
				_backgroundBaseRect.height *= CoreSettings.GLOBAL_SCALING;
			}
		}

		private function onChangeRenderRect(rect : Rectangle) : void
		{
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
		
		//Mario - I will probably land in hell for this:
		public function get renderRect():Rectangle
		{
			return _lightingRenderer.renderRect;
		}
		
		public function set sourceTextureAlpha( value:Number ):void
		{
			_lightingRenderer.sourceTextureAlpha  = value;
		}
		
		public function set paintAlpha( value:Number ):void
		{
			_lightingRenderer.paintAlpha  = value;
		}

		public function init(module : PaintModule = null) : void
		{
			_paintModule = module;
			if (!_paintModule) throw "CanvasRenderer needs to be initialized with a PaintModule first";

			_context3D = stage3D.context3D;
		}

		public function render() : void
		{
			_context3D = stage3D.context3D;

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
				CopySubTexture.copy(_background.texture, new Rectangle(0, 0, 1, 1), backgroundRect, _context3D);
			}
		}

		private function createBackgroundRect() : Rectangle
		{
			var canvasRect : Rectangle = _lightingRenderer.renderRect;
			var rect : Rectangle = new Rectangle();

			// transformation matrix originalRect -> renderRect
			var scaleX : Number = canvasRect.width / _backgroundBaseRect.width;
			var scaleY : Number = canvasRect.height / _backgroundBaseRect.height;
			var tx : Number = canvasRect.x - scaleX*_backgroundBaseRect.x;
			var ty : Number = canvasRect.y - scaleY*_backgroundBaseRect.y;

			// apply matrix to background rect (= 0, 0, 1, 1)
			rect.width = scaleX;
			rect.height = scaleY;
			rect.x = tx/canvas.width;
			rect.y = ty/canvas.height;

			return rect;
		}

		private function isBackgroundVisible() : Boolean
		{
			return _background && (	renderRect.left > 0 || renderRect.right < canvas.width ||
									renderRect.top > 0 || renderRect.bottom < canvas.height);
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
