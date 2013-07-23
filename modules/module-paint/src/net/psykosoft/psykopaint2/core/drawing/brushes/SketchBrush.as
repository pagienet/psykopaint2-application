package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SketchMesh;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	
	public class SketchBrush extends SplatBrushBase
	{

		private var rng:LCG;
		private var _surfaceRelief : PsykoParameter;
		

		public function SketchBrush()
		{
			super(false);
			rng = new LCG(Math.random() * 0xffffff);
			type = BrushType.SKETCH;

			_surfaceRelief = new PsykoParameter( PsykoParameter.NumberParameter, "Surface influence", .6, 0, 1.0);
			_shininess.numberValue = .3;
			_glossiness.numberValue = .25;
			_bumpiness.numberValue = .6;
			_parameters.push(_surfaceRelief);
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer:CanvasRenderer) : void
		{
			super.activate(view, context, canvasModel, renderer);
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

		override protected function createColorStrategy() : IColorStrategy
		{
			return new PyramidMapTdsiStrategy(_canvasModel);
		}

		override protected function onPickColor( point : SamplePoint, pickRadius:Number, smoothFactor:Number ) : void
		{
			
			var minSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.lowerRangeValue);
			var maxSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.upperRangeValue);
			var rsize : Number = minSize + (maxSize - minSize) * point.size;
			if (rsize > maxSize) rsize = maxSize;
			else if (rsize < minSize) rsize = minSize;
			
			appendVO.size = rsize * pickRadius;
			appendVO.point = point;
			_colorStrategy.getColorsByVO( appendVO, rsize* 0.5 * smoothFactor);
		}

		
		override protected function processPoint( point : SamplePoint) : void
		{
			var minSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.lowerRangeValue);
			var maxSize:Number = (_minBrushRenderSize + ( _maxBrushRenderSize - _minBrushRenderSize ) * _sizeFactor.upperRangeValue);
			var rsize:Number = minSize + (maxSize - minSize) * point.size;
			
			if (rsize > maxSize) rsize = maxSize;
			else if (rsize < minSize) rsize = minSize;

			//(_view as Sprite).graphics.drawCircle( point.x, point.y,rsize);
			
			appendVO.uvBounds.x = int(rng.getNumber(0, shapeVariations[0])) * shapeVariations[2];
			appendVO.uvBounds.y = int(rng.getNumber(0, shapeVariations[1])) * shapeVariations[3];
			appendVO.size = rsize * _canvasScaleW; 
			appendVO.point = point;
			_brushMesh.append(appendVO);
		}


		override protected function drawBrushColor() : void
		{
			SketchMesh(_brushMesh).setSurfaceRelief(_surfaceRelief.numberValue);
			super.drawBrushColor();
		}
	}
}
