package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.errors.AbstractMethodError;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.actions.CanvasSnapShot;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.BrushShapeLibrary;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.AbstractBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.StrokeAppendVO;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.IPointDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.PointDecoratorFactory;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;

	public class AbstractBrush extends EventDispatcher
	{
		public static var STROKE_STARTED:String = "strokeStarted";
		public static var STROKE_ENDED:String = "strokeEnded";

		public static var brushShapeLibrary:BrushShapeLibrary;

		public static const PARAMETER_IL_SHAPES:String = "Shapes";
		public static const PARAMETER_NR_SIZE_FACTOR:String = "Size Factor";
		public static const PARAMETER_N_SHININESS:String = "Shininess";
		public static const PARAMETER_N_GLOSSINESS:String = "Glossiness";
		public static const PARAMETER_N_BUMPINESS:String = "Bumpiness";
		public static const PARAMETER_N_BUMP_INFLUENCE:String = "Bump Influence";
		public static const PARAMETER_SL_BLEND_MODE:String = "Blend Mode";
		public static const PARAMETER_N_QUAD_OFFSET_RATIO:String = "Stroke Attachment Ratio";
		public static const PARAMETER_N_CURVATURE_INFLUENCE:String = "Curvature Size Influence";

		protected const _brushScalingFactor:Number = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1;
		protected var _maxBrushRenderSize:Number;

		protected var _canvasModel:CanvasModel;
		protected var _view:DisplayObject;
		protected var _pathManager:PathManager;
		protected var _colorStrategy:IColorStrategy;
		protected var _brushShape:AbstractBrushShape;
		protected var _brushMesh:IBrushMesh;
		protected var _appendVO:StrokeAppendVO;
		protected var _bounds:Rectangle;
		protected var _renderInvalid:Boolean;
		protected var _firstPoint:Boolean;

		protected var _shapeVariations:Vector.<Number>;
		protected var _rotationRange:Number;
		protected var _canvasScaleW:Number;
		protected var _canvasScaleH:Number;

		protected var _parameters:Vector.<PsykoParameter>;

		public var param_sizeFactor:PsykoParameter;
		public var param_shininess:PsykoParameter;
		public var param_glossiness:PsykoParameter;
		public var param_bumpiness:PsykoParameter;
		public var param_bumpInfluence:PsykoParameter;
		public var param_shapes:PsykoParameter;
		public var param_blendMode:PsykoParameter;
		public var param_quadOffsetRatio:PsykoParameter;
		public var param_curvatureSizeInfluence:PsykoParameter;

		protected var _context:Context3D;
		private var _inProgress:Boolean;

		private var _drawNormalsOrSpecular:Boolean;
		private var _type:String;
		protected var _snapshot:CanvasSnapShot;
		protected var _paintSettingsModel:UserPaintSettingsModel;

		public function AbstractBrush(drawNormalsOrSpecular:Boolean)
		{
			_drawNormalsOrSpecular = drawNormalsOrSpecular;

			_parameters = new Vector.<PsykoParameter>();
			param_shapes = new PsykoParameter(PsykoParameter.IconListParameter, PARAMETER_IL_SHAPES, 0, ["basic"]);
			param_sizeFactor = new PsykoParameter(PsykoParameter.NumberRangeParameter, PARAMETER_NR_SIZE_FACTOR, 0, 1, 0, 1);
			param_quadOffsetRatio = new PsykoParameter(PsykoParameter.NumberParameter, PARAMETER_N_QUAD_OFFSET_RATIO, 0, -0.5, 0.5);
			param_curvatureSizeInfluence = new PsykoParameter(PsykoParameter.NumberParameter, PARAMETER_N_CURVATURE_INFLUENCE, 1, 0, 1);

			param_shininess = new PsykoParameter(PsykoParameter.NumberParameter, PARAMETER_N_SHININESS, 0.4, 0, 1);
			param_glossiness = new PsykoParameter(PsykoParameter.NumberParameter, PARAMETER_N_GLOSSINESS, 0.4, 0.01, 1);
			param_bumpiness = new PsykoParameter(PsykoParameter.NumberParameter, PARAMETER_N_BUMPINESS, 1, 0, 1);
			param_bumpInfluence = new PsykoParameter(PsykoParameter.NumberParameter, PARAMETER_N_BUMP_INFLUENCE, 0.6, 0, 1);
			param_blendMode = new PsykoParameter(PsykoParameter.StringListParameter, PARAMETER_SL_BLEND_MODE, 0, [Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO, Context3DBlendFactor.SOURCE_ALPHA]);

			_parameters.push(param_shapes, param_sizeFactor, param_blendMode, param_quadOffsetRatio);
			if (drawNormalsOrSpecular)
				_parameters.push(param_shininess, param_glossiness, param_bumpiness, param_bumpInfluence);

			_bounds = new Rectangle();

			_appendVO = new StrokeAppendVO();
		}

		// only to be implemented by brushes animating/simulating after finalizing the stroke to knock it off
		// used for instance on undo
		public function stopProgression():void
		{

		}

		public function dispose():void
		{
			if (_brushShape) {
				_brushShape.dispose();
				_brushShape = null;
			}
		}

		protected function createBrushMesh():IBrushMesh
		{
			throw new AbstractMethodError();
		}

		public function setPathEngine(data:XML):void
		{
			_pathManager = new PathManager(int(data.@type));
			_pathManager.updateParametersFromXML(data);

			_pathManager.setCallbacks(this, onPathPoints, onPathStart, onPathEnd, onPickColor);
			for (var i:int = 0; i < data.children().length(); i++) {
				if (XML(data.children()[i]).name() != "parameter") {
					_pathManager.addPointDecorator(PointDecoratorFactory.fromXML(data.children()[i]));
				}
			}

		}

		public function set pathManager(value:PathManager):void
		{
			_pathManager = value;
			pathManager.setCallbacks(this, onPathPoints, onPathStart, onPathEnd, onPickColor);
		}

		public function get pathManager():PathManager
		{
			return _pathManager;
		}

		protected function get brushShape():AbstractBrushShape
		{
			return _brushShape;
		}

		protected function set brushShape(brushShape:AbstractBrushShape):void
		{
			if (_brushShape == brushShape) return;
			//if (_brushShape) _brushShape.dispose();
			_brushShape = brushShape;
			_shapeVariations = _brushShape.variationFactors;
			_appendVO.uvBounds.width = _shapeVariations[2];
			_appendVO.uvBounds.height = _shapeVariations[3];
			_appendVO.diagonalAngle = _shapeVariations[4];
			_appendVO.diagonalLength = _shapeVariations[5];
			_appendVO.quadOffsetRatio = param_quadOffsetRatio.numberValue;
			_rotationRange = _brushShape.rotationRange;
			//TODO: this must take into account the actual brush size based on col/rows
			_maxBrushRenderSize = _brushScalingFactor * (Math.sqrt(128 * 128 * 2) / _shapeVariations[5]);
		}

		protected function onShapeChanged(event:Event):void
		{
			brushShape = brushShapeLibrary.getBrushShape(param_shapes.stringValue);
		}


		public function activate(view:DisplayObject, context:Context3D, canvasModel:CanvasModel, renderer:CanvasRenderer, paintSettingsModel:UserPaintSettingsModel):void
		{
			_brushMesh = createBrushMesh();
			// the purpose of this is to avoid a bit of the delay when drawing the very first time
			_brushMesh.assembleShaderPrograms(context);
			brushShape = brushShapeLibrary.getBrushShape(param_shapes.stringValue);

			_view = view;
			_canvasModel = canvasModel;
			_paintSettingsModel = paintSettingsModel;
			_context = context;
			_pathManager.activate(view, canvasModel, renderer);
			param_shapes.addEventListener(Event.CHANGE, onShapeChanged);

			_colorStrategy ||= createColorStrategy();
		}

		public function deactivate():void
		{
			_renderInvalid = false;
			_pathManager.deactivate();
			param_shapes.removeEventListener(Event.CHANGE, onShapeChanged);
			//if (_brushShape) _brushShape.dispose();
		}

		private function finalizeStroke():void
		{
			if (!_firstPoint) dispatchEvent(new Event(STROKE_ENDED));
		}

		protected function onPathStart():void
		{
			//for debugging only:
			//	(_view as Sprite).graphics.clear();
			//	(_view as Sprite).graphics.lineStyle(0);

			_inProgress = true;
			if (_brushShape) _brushShape.update();
			_brushMesh.clear();

			// sorry, but this was interfering with color transfer so I moved it into the activation method
			//_colorStrategy ||= createColorStrategy();

			_canvasScaleW = 2.0 / _canvasModel.textureWidth;	// 0 - 1
			_canvasScaleH = 2.0 / _canvasModel.textureHeight;	// 0 - 1
			_bounds.setEmpty();

			_firstPoint = true;
		}

		protected function onPathPoints(points:Vector.<SamplePoint>):void
		{
			var len:uint = points.length;

			for (var i:int = 0; i < len; i++) {
				var point:SamplePoint = points[i];
				point.normalizeXY(_canvasScaleW, _canvasScaleH);
				processPoint(point);
			}

			if (_firstPoint) {
				_firstPoint = false;
				dispatchEvent(new Event(STROKE_STARTED));
			}

			invalidateRender();

			growBounds(_brushMesh.getBounds());
		}

		protected function growBounds(increase:Rectangle):void
		{
			if (_bounds.isEmpty()) {
				_bounds.copyFrom(increase);
				return;
			}

			if (increase.left < _bounds.left)
				_bounds.left = increase.left;
			if (increase.right > _bounds.right)
				_bounds.right = increase.right;
			if (increase.top < _bounds.top)
				_bounds.top = increase.top;
			if (increase.bottom > _bounds.bottom)
				_bounds.bottom = increase.bottom;
		}

		protected function onPathEnd():void
		{
			//_view.stage.frameRate = 60;
			// override for async brushes and call finalizeStroke when necessary
			growBounds(_brushMesh.getBounds());
			finalizeStroke();
			_snapshot = null;
			_inProgress = false;
			_renderInvalid = false;
		}

		protected function onPickColor(point:SamplePoint, pickRadius:Number, smoothFactor:Number):void
		{

			if (_paintSettingsModel.colorMode == PaintMode.PHOTO_MODE) {
				_appendVO.size = _brushShape.size * pickRadius;
				_appendVO.point = point;
				_colorStrategy.getColorsByVO(_appendVO, _brushShape.size * 0.5 * smoothFactor);
			} else {
				var target:Vector.<Number> = _appendVO.point.colorsRGBA;
				target[0] = target[4] = target[8] = target[12] = _paintSettingsModel.current_r;
				target[1] = target[5] = target[9] = target[13] = _paintSettingsModel.current_g;
				target[2] = target[6] = target[10] = target[14] = _paintSettingsModel.current_b;
			}
		}

		protected function invalidateRender():void
		{
			// icky!
			if (!_snapshot) return;
			_renderInvalid = true;
		}

		protected function processPoint(point:SamplePoint):void
		{
			addStrokePoint(point, _brushShape.actualSize * _canvasScaleW, _brushShape.rotationRange);
		}

		protected function addStrokePoint(point:SamplePoint, size:Number, rotationRange:Number):void
		{
			_appendVO.size = size;
			_appendVO.point = point;
			_brushMesh.append(_appendVO);
		}

		protected function createColorStrategy():IColorStrategy
		{
			throw new AbstractMethodError();
			return null;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function freeExpendableMemory():void
		{
			if (!_inProgress) {
				AbstractBrushMesh.freeExpendableStaticMemory();
			}
		}

		// move brush stroke programs etc to here?
		public function draw():void
		{
			if (!_renderInvalid) return;

			drawColor();
			if (_drawNormalsOrSpecular)
				drawNormalsAndSpecular();

			_renderInvalid = false;
			_context.setRenderToBackBuffer();
		}

		protected function drawColor():void
		{
			throw new AbstractMethodError();
		}

		protected function drawNormalsAndSpecular():void
		{
			throw new AbstractMethodError();
		}

		// default behaviour
		protected function drawBrushColor():void
		{
			_brushMesh.drawColor(_context, _canvasModel);
		}

		protected function drawBrushNormalsAndSpecular():void
		{
			_brushMesh.drawNormalsAndSpecular(_context, _canvasModel, param_shininess.numberValue, param_glossiness.numberValue, param_bumpiness.numberValue, param_bumpInfluence.numberValue);
		}

		public function getParameterSetAsXML(path:Array):XML
		{
			var brushParameters:XML = <brush/>;
			var brushPath:Array = path.concat(["brush"])
			for (var i:int = 0; i < _parameters.length; i++) {
				brushParameters.appendChild(_parameters[i].toXML(brushPath));
			}

			brushParameters.appendChild(_pathManager.getParameterSetAsXML(path));
			//brushParameters.appendChild( getAvailableBrushShapes() );
			return brushParameters;
		}


		public function getParameterSet(vo:ParameterSetVO, showInUiOnly:Boolean):void
		{
			for (var i:int = 0; i < _parameters.length; i++) {
				if (!showInUiOnly || _parameters[i].showInUI > -1)
					vo.parameters.push(_parameters[i]);
			}

			_pathManager.getParameterSet(vo, showInUiOnly);

		}

		public function updateParametersFromXML(message:XML):void
		{
			for (var j:int = message.parameter.length(); --j > -1;) {
				var parameter:XML = message.parameter[j];
				var path:Array = String(parameter.@path).split(".");
				if (path[0] == "brush") {
					var parameterID:String = String(parameter.@id);
					for (var i:int = 0; i < _parameters.length; i++) {
						if (_parameters[i].id == parameterID) {
							_parameters[i].updateValueFromXML(parameter);
							break;
						}
					}
					delete message.parameter[j];
				}
			}

			_pathManager.updateParametersFromXML(message);
		}

		public function getParameter(parameterID:String):PsykoParameter
		{
			for (var i:int = 0; i < _parameters.length; i++) {
				if (_parameters[i].id == parameterID) {
					return _parameters[i];
				}
			}
			return null;
		}

		/*
		 public function addAvailableShape( type:String):void
		 {
		 _availableBrushShapes.appendChild( <shape type={type}/> );

		 }

		 public function removeAvailableShapeAt( index:int):void
		 {
		 delete _availableBrushShapes.children()[index];

		 }
		 */

		public function getParameterByPath(path:Array):PsykoParameter
		{
			if (path.length == 2 && path[0] == "brush") {
				var parameterID:String = path[1];
				for (var i:int = 0; i < _parameters.length; i++) {
					if (_parameters[i].id == parameterID) {
						return _parameters[i];
					}
				}
			}
			return _pathManager.getParameterByPath(path);
		}

		public function getDecoratorByPath(target_path:String):IPointDecorator
		{
			return _pathManager.getDecoratorByPath(target_path);
		}

		public function get snapshot():CanvasSnapShot
		{
			return _snapshot;
		}

		public function set snapShot(value:CanvasSnapShot):void
		{
			_snapshot = value;
			if (!value)
				_renderInvalid = false;
		}

		public function setColorStrategyColorMatrix(colorMatrix:Vector.<Number>, blendFactor:Number):void
		{
			_colorStrategy.setColorMatrix(colorMatrix, blendFactor);
		}

		public function get isStrokeInProgress():Boolean
		{
			return _inProgress;
		}
	}
}
