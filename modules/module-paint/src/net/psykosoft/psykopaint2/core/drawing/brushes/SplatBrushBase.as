package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DStencilAction;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedRectTexture;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedTexture;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapIntrinsicsStrategy;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopyTextureWithAlpha;

	public class SplatBrushBase extends AbstractBrush
	{
		public static const PARAMETER_N_STROKE_ALPHA:String = "Stroke Alpha";
		public var param_strokeAlpha:PsykoParameter;
		
		protected var _incrementalWorkerTexture:TrackedRectTexture;
		
		public function SplatBrushBase(drawNormalsOrSpecular : Boolean)
		{
			super(drawNormalsOrSpecular);
			
			param_strokeAlpha = new PsykoParameter(PsykoParameter.NumberParameter, PARAMETER_N_STROKE_ALPHA, 1, 0, 1);
			_parameters.push(param_strokeAlpha);
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			return new PyramidMapIntrinsicsStrategy(_canvasModel);
		}

		override public function dispose():void
		{
			super.dispose();
			disposeWorkerTexture();
		}

		override public function draw():void
		{
			super.draw();
			_brushMesh.clear();
		}

		override public function activate(view:DisplayObject, context:Context3D, canvasModel:CanvasModel, renderer:CanvasRenderer, paintSettingsModel:UserPaintSettingsModel):void
		{
			super.activate(view, context, canvasModel, renderer, paintSettingsModel);
			if (!_incrementalWorkerTexture) {
				_incrementalWorkerTexture = _canvasModel.createCanvasTexture(true);
				clearWorkerTexture();
			}
		}

		private function clearWorkerTexture():void
		{
			_context.setRenderToTexture(_incrementalWorkerTexture.texture);
			_context.clear(0, 0, 0, 0);
			_context.setRenderToBackBuffer();
		
		}

		override public function deactivate():void
		{
			super.deactivate();
			disposeWorkerTexture();
		}

		private function disposeWorkerTexture():void
		{
			if (_incrementalWorkerTexture) {
				_incrementalWorkerTexture.dispose();
				_incrementalWorkerTexture = null;
			}
		}

		override protected function onPathStart():void
		{
			super.onPathStart();
			clearWorkerTexture();
		}

		override protected function drawColor():void
		{
			// draw brush stroke to incremental texture
			_context.setRenderToTexture(_canvasModel.fullSizeBackBuffer, false)
			_context.clear(0, 0, 0, 0);
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopyTexture.copy(_incrementalWorkerTexture.texture, _context);
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			drawBrushColor();

			_incrementalWorkerTexture = _canvasModel.swapFullSized(_incrementalWorkerTexture);

			_context.setRenderToTexture(_canvasModel.colorTexture, false);
			_context.clear();

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

			_snapshot.drawColor();
			_context.setStencilActions();

			_context.setBlendFactors(param_blendModeSource.stringValue, param_blendModeTarget.stringValue);
			//_context.setBlendFactors(Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

			//CopyTexture.copy(_incrementalWorkerTexture.texture, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
			CopyTextureWithAlpha.copy(_incrementalWorkerTexture.texture, _context, param_strokeAlpha.numberValue);
			
		}



		override protected function drawNormalsAndSpecular():void
		{
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			_context.setRenderToTexture(_canvasModel.fullSizeBackBuffer, false);
			_context.clear();

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopyTexture.copy(_canvasModel.normalSpecularMap, _context);

			_context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			drawBrushNormalsAndSpecular();

			_canvasModel.swapNormalSpecularLayer();
		}


	}
}
