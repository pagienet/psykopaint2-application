package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DStencilAction;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	
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
	import net.psykosoft.psykopaint2.core.errors.AbstractMethodError;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;
	
	public class AbstractBrush extends EventDispatcher
	{
		public static var STROKE_STARTED : String = "strokeStarted";
		public static var STROKE_ENDED : String = "strokeEnded";

		public static var brushShapeLibrary:BrushShapeLibrary;
		
		protected var _canvasModel : CanvasModel;
		protected var _view : DisplayObject;

		protected var _pathManager : PathManager;

		protected var _colorStrategy : IColorStrategy;

		protected var _brushShape : AbstractBrushShape;

		protected var shapeVariations : Vector.<Number>;
		protected var rotationRange : Number;

		private var _type : String;
		protected var _canvasScaleW : Number;
		protected var _canvasScaleH : Number;
		protected var _firstPoint : Boolean;
		
		protected var _parameters:Vector.<PsykoParameter>;
		protected var _opacity:PsykoParameter;
		protected var _colorBlend:PsykoParameter;
		protected var _sizeFactor:PsykoParameter;
		protected var _shininess:PsykoParameter;
		protected var _glossiness:PsykoParameter;
		protected var _bumpiness:PsykoParameter;
		protected var _shapes:PsykoParameter;

		
		protected var appendVO : StrokeAppendVO;
		protected var _brushMesh : IBrushMesh;
		protected var _bounds : Rectangle;
		protected var _renderInvalid : Boolean;

		protected var _context : Context3D;
		private var _inProgress : Boolean;
		private var _incremental : Boolean;
		private var _depthStencil : Boolean;

		private var _drawNormalsOrSpecular : Boolean;
		private var _snapshot : CanvasSnapShot;

		public function AbstractBrush(drawNormalsOrSpecular : Boolean, incremental : Boolean = true, useDepthStencil : Boolean = false)
		{
			_drawNormalsOrSpecular = drawNormalsOrSpecular;
			_depthStencil = useDepthStencil;
			_incremental = incremental;
			_parameters = new Vector.<PsykoParameter>();
			_shapes    = new PsykoParameter( PsykoParameter.IconListParameter, "Shapes",0,["basic"]);
			
		//	_opacity    = new PsykoParameter( PsykoParameter.NumberRangeParameter, "Opacity",0.5,1,0,1);
		//	_colorBlend = new PsykoParameter( PsykoParameter.NumberRangeParameter, "Color Blending",0.5,1,0,1);
			_sizeFactor = new PsykoParameter( PsykoParameter.NumberRangeParameter, "Size Factor",0,1,0,1 );
			
			_shininess    = new PsykoParameter( PsykoParameter.NumberParameter, "Shininess",0.4,0,1);
			_glossiness = new PsykoParameter( PsykoParameter.NumberParameter, "Glossiness",0.4,0.01,1);
			_bumpiness = new PsykoParameter( PsykoParameter.NumberParameter, "Bumpyness",1,0,1 );
			
			
			_parameters.push( _shapes, _sizeFactor); //_opacity, _colorBlend, 

			if (drawNormalsOrSpecular)
				_parameters.push(_shininess,_glossiness,_bumpiness);

			_bounds = new Rectangle();

			appendVO = new StrokeAppendVO();
		}

		// only to be implemented by brushes animating/simulating after finalizing the stroke to knock it off
		// used for instance on undo
		public function stopProgression() : void
		{

		}

		protected function createBrushMesh() : IBrushMesh
		{
			throw new AbstractMethodError();
		}

		/*
		public function getAvailableBrushShapes() : XML
		{
			return _availableBrushShapes;
		}
		
		
		public function setAvailableBrushShapes( data:XML ) : void
		{
			_availableBrushShapes = data;
		}
		*/
		
		public function setPathEngine( data:XML ) : void
		{
			_pathManager = new PathManager(int(data.@type));
			_pathManager.updateParametersFromXML( data );
			
			_pathManager.setCallbacks(this, onPathPoints, onPathStart, onPathEnd, onPickColor);
			for ( var i:int = 0; i < data.children().length(); i++ )
			{
				if ( XML(data.children()[i]).name() != "parameter" )
				{
					_pathManager.addPointDecorator( PointDecoratorFactory.fromXML(data.children()[i]));
				}
			}
			
		}

		public function get pathManager() : PathManager
		{
			return _pathManager;
		}

		protected function get brushShape() : AbstractBrushShape
		{
			return _brushShape;
		}
		
		protected function set brushShape(brushShape : AbstractBrushShape) : void
		{
			if (_brushShape == brushShape) return;
			if (_brushShape) _brushShape.freeMemory();
			_brushShape = brushShape;
			shapeVariations = _brushShape.variationFactors;
			appendVO.uvBounds.width = shapeVariations[2];
			appendVO.uvBounds.height = shapeVariations[3];

			rotationRange = _brushShape.rotationRange;
		}
		
		protected function onShapeChanged(event:Event):void
		{
			brushShape = brushShapeLibrary.getBrushShape(_shapes.stringValue);
		}
		
		
		public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel) : void
		{
			_brushMesh = createBrushMesh();
			brushShape = brushShapeLibrary.getBrushShape(_shapes.stringValue);
			
			_view = view;
			_canvasModel = canvasModel;
			_context = context;
			_pathManager.activate(view,canvasModel);
			_shapes.addEventListener( Event.CHANGE, onShapeChanged );
		}
		
		public function deactivate() : void
		{
			_pathManager.deactivate();
			_shapes.removeEventListener( Event.CHANGE, onShapeChanged );
			if (_brushShape) _brushShape.freeMemory();
		}

		private function finalizeStroke() : void
		{
			dispatchEvent(new Event(STROKE_ENDED));
		}

		protected function onPathStart() : void
		{
			dispatchEvent(new Event(STROKE_STARTED));

			_inProgress = true;
			if (_brushShape) _brushShape.update();
			_brushMesh.clear();
			_colorStrategy ||= createColorStrategy();
			_canvasScaleW = 2.0 / _canvasModel.textureWidth;	// 0 - 1
			_canvasScaleH = 2.0 / _canvasModel.textureHeight;	// 0 - 1
			_bounds.setEmpty();

			// TODO: REQUEST SNAPSHOT

			_firstPoint = true;
		}

		protected function onPathPoints(points : Vector.<SamplePoint>) : void
		{
			var len : uint = points.length;

			for (var i : int = 0; i < len; i++) {
				var point : SamplePoint = points[i];
				point.normalizeXY(_canvasScaleW,_canvasScaleH);
				processPoint( point );
			}
			_firstPoint = false;
			

			invalidateRender();

			growBounds(_brushMesh.getBounds());
		}

		private function growBounds(increase : Rectangle) : void
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

		protected function onPathEnd() : void
		{
			//_view.stage.frameRate = 60;
			// override for async brushes and call finalizeStroke when necessary
			growBounds(_brushMesh.getBounds());
			finalizeStroke();
			_inProgress = false;
			_renderInvalid = false;
		}
		
		protected function onPickColor( point : SamplePoint, colorsRGBA:Vector.<Number> ) : void
		{
			_colorStrategy.getColors(point, _brushShape.size, _brushShape.size, colorsRGBA );
		}

		protected function invalidateRender() : void
		{
			_renderInvalid = true;
		}

		protected function processPoint(point : SamplePoint) : void
		{
			//_colorStrategy.getColors(x, y, _brushShape.size, _brushShape.size, point.colorsRGBA);
			addStrokePoint(point, _brushShape.actualSize * _canvasScaleW, _brushShape.rotationRange);
		}

		protected function addStrokePoint(point : SamplePoint, size : Number, rotationRange : Number) : void
		{
			//appendVO.x = point.normalX;
			//appendVO.y = point.normalY;
			appendVO.size = size;
			//appendVO.rotation = point.angle;
			appendVO.point = point;
			_brushMesh.append(appendVO);
		}

		protected function createColorStrategy() : IColorStrategy
		{
			throw new AbstractMethodError();
			return null;
		}

		public function get type() : String
		{
			return _type;
		}

		public function set type(value : String) : void
		{
			_type = value;
		}

		/*
		public function setColorBlending(minColorBlendFactor : Number, maxColorBlendFactor : Number, minimumOpacity : Number, maximumOpacity : Number) : void
		{
			_colorBlend.lowerRangeValue = minColorBlendFactor;
			_colorBlend.upperRangeValue = maxColorBlendFactor;
			_opacity.lowerRangeValue = minimumOpacity;
			_opacity.upperRangeValue = maximumOpacity;
		}
		*/
		public function setBrushSizeFactors(minSizeFactor : Number, maxSizeFactor : Number) : void
		{
			_sizeFactor.lowerRangeValue = minSizeFactor;
			_sizeFactor.upperRangeValue = maxSizeFactor;
		}

		public function freeExpendableMemory() : void
		{
			if (!_inProgress) {
				AbstractBrushMesh.freeExpendableStaticMemory();
			}
		}

		// move brush stroke programs etc to here?
		public function draw() : void
		{
			if (!_renderInvalid) return;

			drawColor();
			if (_drawNormalsOrSpecular)
				drawNormalsAndSpecular();

			_renderInvalid = false;
			_context.setRenderToBackBuffer();

			if (_incremental) _brushMesh.clear();
		}

		private function drawColor() : void
		{
			_context.setRenderToTexture(_canvasModel.fullSizeBackBuffer, _depthStencil || (_incremental && !_inProgress));
			_context.clear();

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

			if (_incremental) {
				CopyTexture.copy(_canvasModel.colorTexture, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
			}
			else {
				_context.setStencilReferenceValue(1);
				_context.setStencilActions("frontAndBack", "always", Context3DStencilAction.SET, Context3DStencilAction.SET, Context3DStencilAction.SET);
				_snapshot.drawColor();
				_context.setStencilReferenceValue(0);
				_context.setStencilActions("frontAndBack", Context3DCompareMode.EQUAL, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP);
				if (!_inProgress) CopyTexture.copy(_canvasModel.colorTexture, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
				_context.setStencilActions();
			}

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

			drawBrushColor();

			_canvasModel.swapColorLayer();
		}

		private function drawNormalsAndSpecular() : void
		{
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			_context.setRenderToTexture(_canvasModel.fullSizeBackBuffer, _depthStencil || (_incremental && !_inProgress));
			_context.clear();

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			if (_incremental)
				CopyTexture.copy(_canvasModel.normalSpecularMap, _context, _canvasModel.usedTextureWidthRatio, _canvasModel.usedTextureHeightRatio);
			else
				throw "Non-incremental normal/speculars not supported yet";

			drawBrushNormalsAndSpecular();

			_canvasModel.swapNormalSpecularLayer();
		}

		// default behaviour
		protected function drawBrushColor() : void
		{
			_brushMesh.drawColor(_context, _canvasModel);
		}

		protected function drawBrushNormalsAndSpecular() : void
		{
			_brushMesh.drawNormalsAndSpecular(_context, _canvasModel, _shininess.numberValue, _glossiness.numberValue, _bumpiness.numberValue);
		}

		public function getParameterSetAsXML( path:Array ):XML
		{
			var brushParameters:XML = <brush/>;
			var brushPath:Array = path.concat(["brush"])
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				brushParameters.appendChild( _parameters[i].toXML(brushPath) );
			}
			
			brushParameters.appendChild( _pathManager.getParameterSetAsXML(path) );
			//brushParameters.appendChild( getAvailableBrushShapes() );
			return brushParameters;
		}
		
		
		public function getParameterSet( vo:ParameterSetVO, showInUiOnly:Boolean ):void
		{
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				if ( !showInUiOnly || _parameters[i].showInUI )
					vo.parameters.push( _parameters[i] );
			}
			
			_pathManager.getParameterSet( vo, showInUiOnly);
			
		}
		
		public function updateParametersFromXML(message:XML):void
		{
			for ( var j:int = message.parameter.length(); --j >-1 ;  )
			{
				var parameter:XML = message.parameter[j];
				var path:Array = String(parameter.@path).split(".");
				if ( path[0] == "brush" )
				{
					var parameterID:String = String( parameter.@id );
					for ( var i:int = 0; i < _parameters.length; i++ )
					{
						if( _parameters[i].id == parameterID )
						{
							_parameters[i].updateValueFromXML(parameter);
							break;
						}
					}
					delete message.parameter[j];
				}
			}
			
			_pathManager.updateParametersFromXML( message );
		}
		
		public function getParameter( parameterID:String ):PsykoParameter
		{
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				if( _parameters[i].id == parameterID )
				{
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
			if ( path.length == 1 && path[0] == "brush" )
			{
				var parameterID:String = path[1];
				for ( var i:int = 0; i < _parameters.length; i++ )
				{
					if( _parameters[i].id == parameterID )
					{
						return _parameters[i];
					}
				}
			}
			return _pathManager.getParameterByPath( path );
		}
		
		public function getDecoratorByPath(target_path:String):IPointDecorator
		{
			return _pathManager.getDecoratorByPath(target_path);
		}

		public function set snapShot(value : CanvasSnapShot) : void
		{
			_snapshot = value;
		}
	}
}
