package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.drawing.BrushType;

	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;

	import net.psykosoft.psykopaint2.core.drawing.shaders.SinglePigmentBlotTransfer;
	import net.psykosoft.psykopaint2.core.drawing.shaders.StrokeColorTransfer;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.ApplySlope;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.MovePigment;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.MovePigmentRGB;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.RenderPigment;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.RelaxDivergence;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.TransferPigment;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.UpdateVelocities;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	public class WaterColorBrush extends SimulationBrush
	{
		private var _velocityPressureField : Texture;
		private var _velocityPressureFieldBackBuffer : Texture;
		private var _pigmentDensityField : Texture;
		private var _pigmentColorField : Texture;

		private var _addPigmentToPigmentDensity : SinglePigmentBlotTransfer;
		private var _addPigmentToPigmentColor : StrokeColorTransfer;
		private var _addPigmentToPressure : SinglePigmentBlotTransfer;
		private var _addWetness : SinglePigmentBlotTransfer;

		private var _applySlope : ApplySlope;
		private var _updateVelocities : UpdateVelocities;
		private var _relaxDivergence : RelaxDivergence;
		private var _movePigment : MovePigment;
		private var _movePigmentRGB : MovePigmentRGB;
		private var _transferPigment : TransferPigment;
		private var _renderPigment : RenderPigment;

		private var _dt : Number = 1;
		private var _relaxationSteps : int = 3;

		// brush properties:
		private var _surfaceRelief : PsykoParameter;
		private var _waterViscosity : PsykoParameter;
		private var _waterDrag : PsykoParameter;
		private var _pigmentDensity : PsykoParameter;
		private var _pigmentStaining : PsykoParameter;
		private var _pigmentGranulation : PsykoParameter;

		private var _wetBrush : Boolean = false;
		private var _numTriangles : int;



		// IMPORTANT:
		// The simulation runs on a grid, with values associated to each cell
		// Velocity field is a staggered grid, its values represent the values on the boundaries of the actual grid cells
		// We assume (i, j) contains the velocity values for:
		// u(i+.5, j) and v(i, j+.5)
		// This means: when the paper mentions u(i+.5, j), we sample at v(i, j)
		// and u(i+.5, j) ie: sample u --> i - .5, sample v --> j - .5
		// (this because the paper uses uv(i+.5 outputs
		// Staggered values are bilinearly interpolated by the shader

		public function WaterColorBrush()
		{
			super(false);
			_surfaceRelief = new PsykoParameter( PsykoParameter.NumberParameter, "Surface influence", 0.5, 0, 1);
			_waterViscosity = new PsykoParameter( PsykoParameter.NumberParameter, "Viscosity", .2, 0, 1);
			_waterDrag = new PsykoParameter( PsykoParameter.NumberParameter, "Drag", .1, 0, .2);
			_pigmentDensity = new PsykoParameter( PsykoParameter.NumberParameter, "Pigment density", .75, 0, 1);
			_pigmentStaining = new PsykoParameter( PsykoParameter.NumberParameter, "Pigment staining", 5.5, 1, 10);
			_pigmentGranulation = new PsykoParameter( PsykoParameter.NumberParameter, "Pigment granulation", .81, 0, 1);

			_parameters.push( _surfaceRelief, _pigmentDensity, _pigmentStaining, _pigmentGranulation);

			type = BrushType.WATER_COLOR;
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			var strategy : PyramidMapTdsiStrategy = new PyramidMapTdsiStrategy(_canvasModel);
			strategy.setBlendFactors(.1, 1);
			return strategy;
		}

		// reenable this for subtractiveness
//		override protected function createStroke() : IBrushStroke
//		{
//			return new SimulationStroke(true);
//		}

		private function initBuffers() : void
		{
			_velocityPressureField = _canvasModel.createCanvasTexture(true, .25);
			_velocityPressureFieldBackBuffer = _canvasModel.createCanvasTexture(true, .25);
			_pigmentDensityField = _canvasModel.createCanvasTexture(true, .5);
			_pigmentColorField = _canvasModel.createCanvasTexture(true, .5);

			_addPigmentToPigmentDensity = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, SinglePigmentBlotTransfer.TARGET_X);
			_addPigmentToPigmentColor = new StrokeColorTransfer(_canvasModel.stage3D.context3D);
			if (_wetBrush) {
				_addWetness = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, "w", false);
				_addPigmentToPressure = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, SinglePigmentBlotTransfer.TARGET_Z);
			}
			else {
				_addPigmentToPressure = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, "zw");
			}

			_applySlope = new ApplySlope(_canvasModel);
			_updateVelocities = new UpdateVelocities(_canvasModel);
			_relaxDivergence = new RelaxDivergence(_canvasModel);
			_movePigment = new MovePigment(_canvasModel);
			_movePigmentRGB = new MovePigmentRGB(_canvasModel,.5);
			_transferPigment = new TransferPigment(_canvasModel);
			_renderPigment = new RenderPigment(_canvasModel);
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
				_pigmentDensityField.dispose();
				_pigmentColorField.dispose();
				_applySlope.dispose();
				_updateVelocities.dispose();
				_relaxDivergence.dispose();
				_movePigment.dispose();
				_movePigmentRGB.dispose();
				_transferPigment.dispose();
				_renderPigment.dispose();
				_addPigmentToPressure.dispose();
				_addPigmentToPigmentDensity.dispose();
				_addPigmentToPigmentColor.dispose();
				_velocityPressureField = null;
				_velocityPressureFieldBackBuffer = null;
				_pigmentDensityField = null;
				_pigmentColorField = null;
				_applySlope = null;
				_addPigmentToPressure = null;
				_addPigmentToPigmentDensity = null;
				_addPigmentToPigmentColor = null;
				_updateVelocities = null;
				_relaxDivergence = null;
				_movePigment = null;
				_movePigmentRGB = null;
				_transferPigment = null;
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

			_context.setRenderToTexture(_pigmentDensityField, true);
			_context.clear(0, 0, 0, 0);
			_context.setRenderToTexture(_pigmentColorField, true);
			_context.clear(1, 1, 1, 0);
			CopyTexture.copy(_canvasModel.sourceTexture, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
			_context.setRenderToTexture(_velocityPressureField, true);
			_context.clear(.5,.5, 0, 1);
			_context.setRenderToBackBuffer();


			_addPigmentToPigmentDensity.reset();
			_addPigmentToPigmentColor.reset();
			_addPigmentToPressure.reset();
			if (_addWetness) _addWetness.reset();

			_numTriangles = 0;
		}

		override protected function updateSimulation() : void
		{
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);

			if (_numTriangles != _brushMesh.numTriangles) {
				addPaintToSimulation();
				_numTriangles = _brushMesh.numTriangles;
			}

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			applySlope();
			updateVelocities();
			relaxDivergence();
			movePigment();
			transferPigment();
		}

		private function addPaintToSimulation() : void
		{
			_addPigmentToPigmentDensity.execute(SimulationMesh(_brushMesh), _pigmentDensityField, _canvasModel.halfSizeBackBuffer, _brushShape.texture, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
			_pigmentDensityField = _canvasModel.swapHalfSized(_pigmentDensityField);

//			_addPigmentToPigmentColor.execute(SimulationMesh(_brushMesh), _pigmentColorField, _canvasModel.halfSizeBackBuffer, null, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
//			_pigmentColorField = _canvasModel.swapHalfSized(_pigmentColorField);

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

		public function applySlope() : void
		{
			_applySlope.surfaceRelief = _surfaceRelief.numberValue;
			_applySlope.execute(_context, SimulationMesh(_brushMesh), _velocityPressureField, _velocityPressureFieldBackBuffer);
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
			_movePigment.execute(_context, SimulationMesh(_brushMesh), _pigmentDensityField, _velocityPressureField);
			_pigmentDensityField = _canvasModel.swapHalfSized(_pigmentDensityField);

			_movePigmentRGB.execute(_context, SimulationMesh(_brushMesh), _pigmentColorField, _canvasModel.halfSizeBackBuffer, _velocityPressureField, 1, 0, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
			_pigmentColorField = _canvasModel.swapHalfSized(_pigmentColorField);
		}

		private function transferPigment() : void
		{
			_transferPigment.execute(_context, SimulationMesh(_brushMesh), _pigmentDensityField, _pigmentGranulation.numberValue, _pigmentDensity.numberValue, _pigmentStaining.numberValue);
			_pigmentDensityField = _canvasModel.swapHalfSized(_pigmentDensityField);
		}

		override protected function drawBrushColor() : void
		{
//			CopyTexture.copy(_velocityPressureField, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
//			CopyTexture.copy(_pigmentDensityField, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
//			CopyTexture.copy(_pigmentColorField.texture, context3d);

			_renderPigment.execute(_context, SimulationMesh(_brushMesh), _pigmentDensityField, _pigmentColorField);
		}

		override public function freeExpendableMemory() : void
		{
			super.freeExpendableMemory();

			if (_brushMesh == null)
				clearMemory();
		}
	}
}
