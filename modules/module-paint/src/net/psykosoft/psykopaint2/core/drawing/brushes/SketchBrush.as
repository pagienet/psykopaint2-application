package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SketchMesh;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	
	public class SketchBrush extends SplatBrushBase
	{
		public static const PARAMETER_N_SURFACE_INFLUENCE : String = "Surface Influence";
		
		private var rng:LCG;
		private var _surfaceRelief : PsykoParameter;
		

		public function SketchBrush()
		{
			super(false);
			rng = new LCG(Math.random() * 0xffffff);
			type = BrushType.SKETCH;

			_surfaceRelief = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_SURFACE_INFLUENCE, .6, 0, 1.0);
			param_shininess.numberValue = .3;
			param_glossiness.numberValue = .25;
			param_bumpiness.numberValue = .6;
			_parameters.push(_surfaceRelief);
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer:CanvasRenderer, paintSettingsModel : UserPaintSettingsModel) : void
		{
			super.activate(view, context, canvasModel, renderer, paintSettingsModel);
			if (_brushShape)
				assignBrushShape();
		}

		override protected function createBrushMesh() : IBrushMesh
		{
			return new SketchMesh();
		}

		override protected function set brushShape(brushShape : AbstractBrushShape) : void
		{
			super.brushShape = brushShape;
			if (_brushMesh)
				assignBrushShape();
			_pathManager.brushAngleRange = brushShape.rotationRange;
		}

		private function assignBrushShape() : void
		{
			SketchMesh(_brushMesh).brushTexture = _brushShape.texture;
			SketchMesh(_brushMesh).pixelUVOffset = 0.5 / _brushShape.size;
			_pathManager.brushAngleRange = brushShape.rotationRange;
		}

		override protected function onPickColor( point : SamplePoint, pickRadius:Number, smoothFactor:Number ) : void
		{
			_appendVO.point = point;
			if ( _paintSettingsModel.colorMode == PaintMode.PHOTO_MODE )
			{
				var rsize : Number = param_sizeFactor.lowerRangeValue + param_sizeFactor.rangeValue * point.size * point.curvature;
				if (rsize > 1) rsize = 1;
				else if (rsize < 0) rsize = 0;
				
				_appendVO.size = _maxBrushRenderSize * rsize * pickRadius;
				_colorStrategy.getColorsByVO( _appendVO, _appendVO.diagonalLength*_maxBrushRenderSize * rsize* 0.25 * smoothFactor);
			} else {
				var target:Vector.<Number> = _appendVO.point.colorsRGBA;
				target[0] = target[4] = target[8] = target[12] = _paintSettingsModel.current_r;
				target[1] = target[5] = target[9] = target[13] = _paintSettingsModel.current_g;
				target[2] = target[6] = target[10] = target[14] = _paintSettingsModel.current_b;
			}
		}

		
		override protected function processPoint( point : SamplePoint) : void
		{
			var rsize : Number = param_sizeFactor.lowerRangeValue + param_sizeFactor.rangeValue * point.size * point.curvature;
			if (rsize > 1) rsize = 1;
			else if (rsize < 0) rsize = 0;
			/*
			var minSize:Number = _maxBrushRenderSize * _sizeFactor.lowerRangeValue;
			var maxSize:Number = _maxBrushRenderSize * _sizeFactor.upperRangeValue;
			
			var rsize:Number = minSize + (maxSize - minSize) * point.size;
			
			if (rsize > maxSize) rsize = maxSize;
			else if (rsize < minSize) rsize = minSize;

			//(_view as Sprite).graphics.drawCircle( point.x, point.y,rsize);
			*/
			_appendVO.uvBounds.x = int(rng.getNumber(0, _shapeVariations[0])) * _shapeVariations[2];
			_appendVO.uvBounds.y = int(rng.getNumber(0, _shapeVariations[1])) * _shapeVariations[3];
			//_appendVO.size = rsize * _canvasScaleW; 
			_appendVO.size = _maxBrushRenderSize * rsize * _canvasScaleW; 
			_appendVO.point = point;
			_brushMesh.append(_appendVO);
		}


		override protected function drawBrushColor() : void
		{
			SketchMesh(_brushMesh).setSurfaceRelief(_surfaceRelief.numberValue);
			super.drawBrushColor();
		}
	}
}
