package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display.BitmapData;
	import flash.display.Stage3D;
	import flash.display.TriangleCulling;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFreezeRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestResumeRenderingSignal;

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
		
		private var _paintModule : PaintModule;

		private var _context3D : Context3D;

		private var _lightingRenderer : LightingRenderer;

		public function CanvasRenderer()
		{

		}

		[PostConstruct]
		public function postConstruct() : void
		{
			_lightingRenderer = new LightingRenderer(lightingModel, stage3D.context3D);
			requestFreezeRendering.add(freezeRendering);
			requestResumeRendering.add(resumeRendering);
			requestChangeRenderRect.add(onChangeRenderRect);
		}

		private function onChangeRenderRect(rect : Rectangle) : void
		{
			_lightingRenderer.renderRect = rect;
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
		
		public function set renderRect( rect : Rectangle):void
		{
			_lightingRenderer.renderRect  = rect;
		}
		
		public function get offsetX():Number
		{
			return _lightingRenderer.offsetX;
		}
		
		public function get offsetY():Number
		{
			return _lightingRenderer.offsetY;
		}
		
		public function get scale():Number
		{
			return _lightingRenderer.scale;
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

			if (lightingModel.lightEnabled) {
				_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
				_lightingRenderer.render(canvas);
			}
			else {
				// todo: if rendering source, add the source to be copied
				var sourceRect : Rectangle = new Rectangle(0, 0, canvas.usedTextureWidthRatio, canvas.usedTextureHeightRatio);
				var destRect : Rectangle = new Rectangle(0, 0, 1, 1);
				CopySubTexture.copy(canvas.fullSizeBackBuffer, sourceRect, destRect, _context3D);
			}

			_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
		}

		public function renderToBitmapData() : BitmapData
		{
			// I am sure there is some way to make the more elegant, but this works for now:
			var map : BitmapData = new BitmapData(canvas.viewport.width, canvas.viewport.height, false, 0xffffffff);

			_context3D.setRenderToBackBuffer();
			_context3D.clear(1, 1, 1, 1);
			_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

			var bb : BackbufferTextureFilter = new BackbufferTextureFilter();
			bb.draw(canvas.colorTexture, _context3D, canvas.usedTextureWidthRatio, canvas.usedTextureHeightRatio);
			_context3D.drawToBitmapData(map);
			_context3D.clear(1, 1, 1, 1);
			return map;
		}
	}
}
