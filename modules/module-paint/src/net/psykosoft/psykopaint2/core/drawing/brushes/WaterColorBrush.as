package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedTexture;
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapIntrinsicsStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationQuadMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationRibbonMesh;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.shaders.SinglePigmentBlotTransfer;
	import net.psykosoft.psykopaint2.core.drawing.shaders.StrokeColorTransfer;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.ApplySlope;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.MovePigment;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.MovePigmentRGB;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.RelaxDivergence;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.RenderPigment;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.TransferPigment;
	import net.psykosoft.psykopaint2.core.drawing.shaders.water.UpdateVelocities;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.rendering.CopyColorTransferTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	public class WaterColorBrush extends SimulationBrush
	{
		public static const OVERLAP_PREVENTION_TRI_COUNT : int = 2;

		public static const PARAMETER_N_SURFACE_INFLUENCE:String = "Surface influence";
		public static const PARAMETER_N_GRAVITY_INFLUENCE:String = "Gravity influence";
		public static const PARAMETER_N_VISCOSITY:String = "Viscosity";
		public static const PARAMETER_N_DRAG:String = "Drag";
		public static const PARAMETER_N_PIGMENT_DENSITY:String = "Pigment density";
		public static const PARAMETER_N_PIGMENT_STAINING:String = "Pigment staining";
		public static const PARAMETER_N_PIGMENT_GRANULATION:String = "Pigment granulation";
		public static const PARAMETER_N_MESH_TYPE:String = "Mesh type";

		private var _velocityPressureField : TrackedTexture;
		private var _halfSizedBackBuffer : TrackedTexture;
		private var _velocityPressureFieldBackBuffer : TrackedTexture;
		private var _pigmentDensityField : TrackedTexture;
		private var _pigmentColorField : TrackedTexture;

		private var _addPigmentToPigmentDensity : SinglePigmentBlotTransfer;
		private var _addPigmentToPigmentColor : StrokeColorTransfer;
		private var _addPigmentToPressure : SinglePigmentBlotTransfer;
		private var _addWetness : SinglePigmentBlotTransfer;

		private var _transferSource : CopyColorTransferTexture;

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

		public var param_surfaceRelief : PsykoParameter;
		public var param_gravityStrength : PsykoParameter;
		public var param_waterViscosity : PsykoParameter;
		public var param_waterDrag : PsykoParameter;
		public var param_pigmentDensity : PsykoParameter;
		public var param_pigmentStaining : PsykoParameter;
		public var param_pigmentGranulation : PsykoParameter;
		public var param_meshType : PsykoParameter;

		private var _wetBrush : Boolean = false;

		// IMPORTANT:
		// The simulation runs on a grid, with values associated to each cell
		// Velocity field is a staggered grid; its values represent the values on the boundaries of the actual grid cells
		// We assume (i, j) contains the velocity values for:
		// u(i+.5, j) and v(i, j+.5)
		// This means: when the paper mentions u(i+.5, j), we sample at v(i, j)
		// and u(i+.5, j) ie: sample u --> i - .5, sample v --> j - .5
		// (this because the paper uses uv(i+.5 outputs
		// Staggered values are bilinearly interpolated by the shader

		public function WaterColorBrush()
		{
			super(false);

			param_surfaceRelief = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_SURFACE_INFLUENCE, 2, 0, 4);
			param_gravityStrength = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_GRAVITY_INFLUENCE, 0.0, 0, .3);
			param_waterViscosity = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_VISCOSITY, .2, 0, 1);
			param_waterDrag = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_DRAG, .1, 0, .2);
			param_pigmentDensity = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_PIGMENT_DENSITY, .25, 0,.4);
			param_pigmentStaining = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_PIGMENT_STAINING,.25, .1,1);
			param_pigmentGranulation = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_PIGMENT_GRANULATION, 1.0, 0, 1);
			// 0 = ribbon, 1 = dots
			param_meshType = new PsykoParameter( PsykoParameter.IntParameter, PARAMETER_N_MESH_TYPE, 0, 0, 1);
			param_meshType.addEventListener(Event.CHANGE, onMeshTypeChange);

			_parameters.push( param_surfaceRelief, param_gravityStrength, param_pigmentDensity, param_pigmentStaining, param_pigmentGranulation);

			param_sizeFactor.lowerRangeValue = .77;
			param_sizeFactor.upperRangeValue = .77;

			type = BrushType.WATER_COLOR;
		}

		private function onMeshTypeChange(event:Event):void
		{
			_brushMesh = createBrushMesh();
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			var strategy : PyramidMapIntrinsicsStrategy = new PyramidMapIntrinsicsStrategy(_canvasModel);
			//strategy.setBlendFactors(.1, 1);
			return strategy;
		}

		// reenable this for subtractiveness
//		override protected function createStroke() : IBrushStroke
//		{
//			return new SimulationStroke(true);
//		}

		override protected function createBrushMesh() : IBrushMesh
		{
			return param_meshType.intValue == 0? new SimulationRibbonMesh() : new SimulationQuadMesh();
		}

		private function initBuffers() : void
		{
			_velocityPressureField = _canvasModel.createCanvasTexture(true, .25);
			_halfSizedBackBuffer = _canvasModel.createCanvasTexture(true, .5);
			_velocityPressureFieldBackBuffer = _canvasModel.createCanvasTexture(true, .25);
			_pigmentDensityField = _canvasModel.createCanvasTexture(true, .5);
			_pigmentColorField = _canvasModel.createCanvasTexture(true, .5);

			// todo: if "connection" was added previously, force last N segments to add water
			_addPigmentToPigmentDensity = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, SinglePigmentBlotTransfer.TARGET_X, true);
			_addPigmentToPigmentColor = new StrokeColorTransfer(_canvasModel.stage3D.context3D);
			if (_wetBrush) {
				_addWetness = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, "w", false);
				_addPigmentToPressure = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, SinglePigmentBlotTransfer.TARGET_Z);
			}
			else {
				_addPigmentToPressure = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, "zw");
			}

			_transferSource = new CopyColorTransferTexture();
			_transferSource.init(_context);
			_applySlope = new ApplySlope(_context, _canvasModel);
			_updateVelocities = new UpdateVelocities(_context, _canvasModel);
			_relaxDivergence = new RelaxDivergence(_context, _canvasModel);
			_movePigment = new MovePigment(_context, _canvasModel);
			_movePigmentRGB = new MovePigmentRGB(_context, _canvasModel,.5);
			_transferPigment = new TransferPigment(_context, _canvasModel);
			_renderPigment = new RenderPigment(_context, _canvasModel);
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
				_halfSizedBackBuffer.dispose();
				_velocityPressureFieldBackBuffer.dispose();
				_pigmentDensityField.dispose();
				_pigmentColorField.dispose();
				_applySlope.dispose();
				_transferSource.dispose();
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
				_transferSource = null;
			}

			if (_addWetness) {
				_addWetness.dispose();
				_addWetness = null;
			}
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer : CanvasRenderer, paintSettingsModel : UserPaintSettingsModel) : void
		{
			super.activate(view, context, canvasModel, renderer, paintSettingsModel);

			if (!_velocityPressureField)
				initBuffers();
		}

		override protected function set brushShape(brushShape : AbstractBrushShape) : void
		{
			super.brushShape = brushShape;
			_wetBrush = brushShape.id == "wet";

			// buffers not created yet, so no need to recreate them here
			if (!_velocityPressureField) return;

			if (_addWetness && !_wetBrush) {
				_addWetness.dispose();
				_addWetness = null;
				_addPigmentToPressure.dispose();
				_addPigmentToPressure = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, "zw");
			}
			else if (!_addWetness && _wetBrush) {
				_addWetness = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, "w", false);
				if (_addPigmentToPressure) _addPigmentToPressure.dispose();
				_addPigmentToPressure = new SinglePigmentBlotTransfer(_canvasModel.stage3D.context3D, SinglePigmentBlotTransfer.TARGET_Z);
			}
		}

		override protected function resetSimulation() : void
		{
			// prevent rendering with a reset brush (results in the previous stroke being deleted if not yet finalized)
			// the ACTUAL cause is lack of synchronisation control between the GPURenderManager's trigger and the "stroke started" event. Sucks.
			_renderInvalid = false;
			_context.setRenderToTexture(_pigmentDensityField.texture, true);
			_context.clear(0, 0, 0, 0);
			_context.setRenderToTexture(_pigmentColorField.texture, true);

			if (_paintSettingsModel.colorMode == PaintMode.COLOR_MODE) {
				_context.clear(_paintSettingsModel.current_r, _paintSettingsModel.current_g, _paintSettingsModel.current_b, 1);
			}
			else {
				_context.clear(1, 1, 1, 0);
				_transferSource.draw(_canvasModel.sourceTexture, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
			}
			_context.setRenderToTexture(_velocityPressureField.texture, true);
			_context.clear(.5,.5, 0, 1);
			_context.setRenderToBackBuffer();

			_addPigmentToPigmentDensity.reset();
			_addPigmentToPigmentColor.reset();
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
			transferPigment();
		}

		private function addPaintToSimulation() : void
		{
			_addPigmentToPigmentDensity.execute(simulationMesh, _pigmentDensityField.texture, _halfSizedBackBuffer.texture, _brushShape.texture, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
			_pigmentDensityField = swapHalfSized(_pigmentDensityField);

//			_addPigmentToPigmentColor.execute(SimulationMesh(_brushMesh), _pigmentColorField, _canvasModel.halfSizeBackBuffer, null, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
//			_pigmentColorField = _canvasModel.swapHalfSized(_pigmentColorField);

			if (_addWetness) {
				_addWetness.execute(simulationMesh, _velocityPressureField.texture, _velocityPressureFieldBackBuffer.texture, null, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
				swapVelocityBuffer();
			}

			_addPigmentToPressure.execute(simulationMesh, _velocityPressureField.texture, _velocityPressureFieldBackBuffer.texture, _brushShape.texture, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
			swapVelocityBuffer();
		}

		private function swapHalfSized(other : TrackedTexture) : TrackedTexture
		{
			var temp : TrackedTexture = _halfSizedBackBuffer;
			_halfSizedBackBuffer = other;
			return temp;
		}

		private function swapVelocityBuffer() : void
		{
			var tmp : TrackedTexture = _velocityPressureField;
			_velocityPressureField = _velocityPressureFieldBackBuffer;
			_velocityPressureFieldBackBuffer = tmp;
		}

		private function applySlope() : void
		{
			var gravity : Vector3D = AccelerometerManager.gravityVector;
			_applySlope.surfaceRelief = param_surfaceRelief.numberValue;
			_applySlope.gravityStrength = param_gravityStrength.numberValue;
			_applySlope.execute(gravity, simulationMesh, _velocityPressureField.texture, _canvasModel.normalSpecularMap, _velocityPressureFieldBackBuffer.texture);
			swapVelocityBuffer();
		}

		private function updateVelocities() : void
		{
			// we keep wetness in velocityPressureField (for now it's always 1)
			_updateVelocities.execute(simulationMesh, _velocityPressureField.texture, _velocityPressureFieldBackBuffer.texture, _dt, param_waterViscosity.numberValue, param_waterDrag.numberValue);
			swapVelocityBuffer();
		}

		private function relaxDivergence() : void
		{
			_relaxDivergence.activate(_context);
			for (var i : int = 0; i < _relaxationSteps; ++i) {
				_relaxDivergence.execute(simulationMesh, _velocityPressureField.texture, _velocityPressureFieldBackBuffer.texture);
				swapVelocityBuffer();
			}
			_relaxDivergence.deactivate(_context);
		}

		private function movePigment() : void
		{
			_movePigment.execute(simulationMesh, _pigmentDensityField.texture, _halfSizedBackBuffer.texture, _velocityPressureField.texture);
			_pigmentDensityField = swapHalfSized(_pigmentDensityField);

			if (_paintSettingsModel.colorMode == PaintMode.PHOTO_MODE) {
				_movePigmentRGB.execute(simulationMesh, _pigmentColorField.texture, _halfSizedBackBuffer.texture, _velocityPressureField.texture, 1, 0, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
				_pigmentColorField = swapHalfSized(_pigmentColorField);
			}
		}

		private function transferPigment() : void
		{
			_transferPigment.execute(simulationMesh, _pigmentDensityField.texture, _halfSizedBackBuffer.texture, param_pigmentGranulation.numberValue, param_pigmentDensity.numberValue, param_pigmentStaining.numberValue);
			_pigmentDensityField = swapHalfSized(_pigmentDensityField);
		}

		override protected function drawBrushColor() : void
		{
//			CopyTexture.copy(_velocityPressureField, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
//			CopyTexture.copy(_pigmentDensityField, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
//			CopyTexture.copy(_pigmentColorField.texture, context3d);

			_renderPigment.execute(simulationMesh, _pigmentDensityField.texture, _pigmentColorField.texture);
		}

		override public function setColorStrategyColorMatrix(colorMatrix:Vector.<Number>, blendFactor:Number):void
		{
			super.setColorStrategyColorMatrix(colorMatrix, blendFactor);
			_transferSource.setColorMatrix(colorMatrix, blendFactor);
		}
	}
}
