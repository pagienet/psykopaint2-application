package net.psykosoft.psykopaint2.core.drawing.brushes
{
 	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.textures.Texture;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.FlatColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.shaders.SinglePigmentBlotTransfer;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.ApplySlope;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.MovePigmentCMYA;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.MovePigmentRGBA;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.RelaxDivergence;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.RenderPigmentRGB;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.UpdateVelocities;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	public class WaterDamageBrush extends SimulationBrush
	{
		private var _velocityPressureField : Texture;
		private var _velocityPressureFieldBackBuffer : Texture;
		private var _pigmentColorField : Texture;
		private var _normalField : Texture;

		private var _addPigmentToPressure : SinglePigmentBlotTransfer;
		private var _addWetness : SinglePigmentBlotTransfer;

		private var _applySlope : ApplySlope;
		private var _updateVelocities : UpdateVelocities;
		private var _relaxDivergence : RelaxDivergence;
		private var _movePigmentCMYA : MovePigmentCMYA;
		private var _movePigmentRGBA : MovePigmentRGBA;
		private var _renderPigment : RenderPigmentRGB;

		private var _dt : Number = 1;
		private var _relaxationSteps : int = 3;

		// brush properties:
		private var _surfaceRelief : PsykoParameter;
		private var _gravityStrength : PsykoParameter;
		private var _waterViscosity : PsykoParameter;
		private var _waterDrag : PsykoParameter;

		private var _pigmentFlow : PsykoParameter;

		private var _wetBrush : Boolean = true;


		// TODO: normal painting

		public function WaterDamageBrush()
		{
			super(false);

			_surfaceRelief = new PsykoParameter( PsykoParameter.NumberParameter, "Surface influence", 0.3, 0, 5);
			_gravityStrength = new PsykoParameter( PsykoParameter.NumberParameter, "Gravity influence", 0.1, 0, .3);
			_waterViscosity = new PsykoParameter( PsykoParameter.NumberParameter, "Viscosity", .1, 0, 1);
			_waterDrag = new PsykoParameter( PsykoParameter.NumberParameter, "Drag",.1, 0, .2);
			_pigmentFlow = new PsykoParameter( PsykoParameter.NumberParameter, "Pigment flow", .5, 0, 1);

			_parameters.push( _surfaceRelief, _gravityStrength, _pigmentFlow);

			type = BrushType.WATER_DAMAGE;
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			// not using this anyway
			return new FlatColorStrategy();
		}

		private function initBuffers() : void
		{
			_velocityPressureField = _canvasModel.createCanvasTexture(true, .25);
			_velocityPressureFieldBackBuffer = _canvasModel.createCanvasTexture(true, .25);
			_pigmentColorField = _canvasModel.createCanvasTexture(true, .5);
			_normalField = _canvasModel.createCanvasTexture(true, .5);

			if (_wetBrush) {
				_addWetness = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, "w", false);
				_addPigmentToPressure = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, SinglePigmentBlotTransfer.TARGET_Z);
			}
			else {
				_addPigmentToPressure = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, "xw");
			}

			_applySlope = new ApplySlope(_canvasModel);
			_updateVelocities = new UpdateVelocities(_canvasModel);
			_relaxDivergence = new RelaxDivergence(_canvasModel);
			_movePigmentCMYA = new MovePigmentCMYA(_canvasModel);
			_movePigmentRGBA = new MovePigmentRGBA(_canvasModel);
			_renderPigment = new RenderPigmentRGB(_canvasModel);
		}

		override public function deactivate() : void
		{
			super.deactivate();
			clearMemory();
		}

		private function clearMemory() : void
		{
			if (_velocityPressureField) {
				_velocityPressureField.dispose();
				_velocityPressureFieldBackBuffer.dispose();
				_pigmentColorField.dispose();
				_normalField.dispose();
				_applySlope.dispose();
				_updateVelocities.dispose();
				_relaxDivergence.dispose();
				_movePigmentCMYA.dispose();
				_movePigmentRGBA.dispose();
				_addPigmentToPressure.dispose();
				_renderPigment.dispose();
				_velocityPressureField = null;
				_velocityPressureFieldBackBuffer = null;
				_applySlope = null;
				_addPigmentToPressure = null;
				_pigmentColorField = null;
				_normalField = null;
				_updateVelocities = null;
				_relaxDivergence = null;
				_movePigmentCMYA = null;
				_movePigmentRGBA = null;
				_renderPigment = null;
			}

			if (_addWetness) {
				_addWetness.dispose();
				_addWetness = null;
			}
		}

		override protected function resetSimulation() : void
		{
			if (!_velocityPressureField)
				initBuffers();

			_context.setRenderToTexture(_pigmentColorField, true);
			_context.clear();
			CopyTexture.copy(_canvasModel.colorTexture, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);

			_context.setRenderToTexture(_normalField, true);
			_context.clear();
			CopyTexture.copy(_canvasModel.normalSpecularMap, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);

			_context.setRenderToTexture(_velocityPressureField, true);
			_context.clear(.5, .5, 0, 1);
			_context.setRenderToBackBuffer();

			_addPigmentToPressure.reset();
			if (_addWetness) _addWetness.reset();
		}

		override protected function updateSimulation() : void
		{
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);

			addPaintToSimulation();

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			applySlope();
			updateVelocities();
			relaxDivergence();
			movePigment();
		}

		private function addPaintToSimulation() : void
		{
			if (_addWetness) {
				_addWetness.execute(SimulationMesh(_brushMesh), _velocityPressureField, _velocityPressureFieldBackBuffer, null, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
				swapVelocityBuffer();
			}

			_addPigmentToPressure.execute(SimulationMesh(_brushMesh), _velocityPressureField, _velocityPressureFieldBackBuffer, _brushShape.texture, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
			swapVelocityBuffer();
		}

		private function swapVelocityBuffer() : void
		{
			var tmp : Texture = _velocityPressureField;
			_velocityPressureField = _velocityPressureFieldBackBuffer;
			_velocityPressureFieldBackBuffer = tmp;
		}

		private function applySlope() : void
		{
			var gravity : Vector3D = AccelerometerManager.gravityVector;
			_applySlope.surfaceRelief = _surfaceRelief.numberValue;
			_applySlope.gravityStrength = _gravityStrength.numberValue;
			_applySlope.execute(_context, gravity, SimulationMesh(_brushMesh), _velocityPressureField, _velocityPressureFieldBackBuffer);
			swapVelocityBuffer();
		}

		private function updateVelocities() : void
		{
			// we keep wetness in velocityPressureField (for now it's always 1)
			_updateVelocities.execute(_context, SimulationMesh(_brushMesh), _velocityPressureField, _velocityPressureFieldBackBuffer, _dt, _waterViscosity.numberValue, _waterDrag.numberValue);
			swapVelocityBuffer();
		}

		private function relaxDivergence() : void
		{
			_relaxDivergence.activate(_context);
			for (var i : int = 0; i < _relaxationSteps; ++i) {
				_relaxDivergence.execute(_context, SimulationMesh(_brushMesh), _velocityPressureField, _velocityPressureFieldBackBuffer);
				swapVelocityBuffer();
			}
			_relaxDivergence.deactivate(_context);
		}

		private function movePigment() : void
		{
			_movePigmentCMYA.execute(_context, SimulationMesh(_brushMesh), _pigmentColorField, _velocityPressureField, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio, _pigmentFlow.numberValue);
			_pigmentColorField = _canvasModel.swapHalfSized(_pigmentColorField);

//			_movePigmentRGBA.execute(_context, SimulationMesh(_brushMesh), _normalField, _velocityPressureField, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio, _pigmentFlow.numberValue);
//			_normalField = _canvasModel.swapHalfSized(_normalField);
		}


		override protected function drawBrushNormalsAndSpecular() : void
		{
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			_renderPigment.execute(_context, SimulationMesh(_brushMesh), _normalField);
		}

		override protected function drawBrushColor() : void
		{
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			_renderPigment.execute(_context, SimulationMesh(_brushMesh), _pigmentColorField);
		}

		override public function freeExpendableMemory() : void
		{
			super.freeExpendableMemory();

			if (_brushMesh == null)
				clearMemory();
		}
	}
}
