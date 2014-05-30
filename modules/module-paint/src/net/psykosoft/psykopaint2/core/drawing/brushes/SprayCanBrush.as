package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	
	import de.popforge.math.LCG;

	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.EraserSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	
	public class SprayCanBrush extends SplatBrushBase
	{

		private var rng:LCG;
		
		public function SprayCanBrush()
		{
			super(true);
			type = BrushType.SPRAY_CAN;
			rng = new LCG(Math.random() * 0xffffff);
			
			param_glossiness.numberValue = .25;
			param_bumpiness.numberValue = .6;
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer:CanvasRenderer, paintSettingsModel : UserPaintSettingsModel) : void
		{
			super.activate(view, context, canvasModel, renderer, paintSettingsModel);
			if (_brushShape)
				assignBrushShape();
		}

		override protected function createBrushMesh() : IBrushMesh
		{
			return param_eraserMode.booleanValue? new EraserSplatMesh() : new TextureSplatMesh();
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
			if (param_eraserMode.booleanValue) {
				EraserSplatMesh(_brushMesh).brushTexture = _brushShape.texture;
				EraserSplatMesh(_brushMesh).normalTexture = _brushShape.normalSpecularMap;
				EraserSplatMesh(_brushMesh).pixelUVOffset = 0.5 / _brushShape.size;
				EraserSplatMesh(_brushMesh).normalSpecularOriginal = _eraserNormalSpecularMap;
			}
			else {
				TextureSplatMesh(_brushMesh).brushTexture = _brushShape.texture;
				TextureSplatMesh(_brushMesh).normalTexture = _brushShape.normalSpecularMap;
				TextureSplatMesh(_brushMesh).pixelUVOffset = 0.5 / _brushShape.size;
			}
			_pathManager.brushAngleRange = brushShape.rotationRange;
		}

		override protected function onPickColor( point : SamplePoint, pickRadius : Number, smoothFactor : Number ) : void
		{
			_appendVO.point = point;
			if ( _paintSettingsModel.colorMode == PaintMode.PHOTO_MODE )
			{
				var rsize : Number = param_sizeFactor.lowerRangeValue + param_sizeFactor.rangeValue * point.size * ( param_curvatureSizeInfluence.numberValue * (point.curvature - 1) + 1);
				if (rsize > 1) rsize = 1;
				else if (rsize < 0) rsize = 0;
				
				_appendVO.size = _maxBrushRenderSize * rsize * pickRadius;
				_colorStrategy.getColorsByVO( _appendVO, _appendVO.diagonalLength*_maxBrushRenderSize *rsize* 0.25 * smoothFactor);
			} else {
				var target:Vector.<Number> = _appendVO.point.colorsRGBA;
				target[0] = target[4] = target[8] = target[12] = _paintSettingsModel.current_r;
				target[1] = target[5] = target[9] = target[13] = _paintSettingsModel.current_g;
				target[2] = target[6] = target[10] = target[14] = _paintSettingsModel.current_b;
			}
		}

		override protected function processPoint( point : SamplePoint) : void
		{
			var rsize : Number = param_sizeFactor.lowerRangeValue + param_sizeFactor.rangeValue * point.size * ( param_curvatureSizeInfluence.numberValue * (point.curvature - 1) + 1);
			if (rsize > 1) rsize = 1;
			else if (rsize < 0) rsize = 0;
			
			_appendVO.uvBounds.x = int(Math.random() * _shapeVariations[0]) * _shapeVariations[2]; 
			_appendVO.uvBounds.y = int(Math.random() * _shapeVariations[1]) * _shapeVariations[3];
		
			_appendVO.size =  rsize * _maxBrushRenderSize;
			_appendVO.point = point;
			_brushMesh.append(_appendVO);
		}

		override protected function onBrushMeshRecreated():void
		{
			if (_brushShape)
				assignBrushShape();
		}
	}
}
