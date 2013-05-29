package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import com.greensock.easing.Quad;

	import flash.display.DisplayObject;

	import flash.display3D.Context3D;

	import flash.geom.Rectangle;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.FlatColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SourceCopyMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SourceCopyMesh;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.resources.ITextureManager;
	
	public class ShatterBrush extends SplatBrushBase
	{
		private var rng:LCG;
		
		public function ShatterBrush()
		{
			super(false);
			rng = new LCG( Math.random() * 0xffffff );
			type = BrushType.SHATTER;
			appendVO.verticesAndUV = new Vector.<Number>(24,true);
			for ( var i:int = 0; i < 24; i++ )
			{
				appendVO.verticesAndUV[i] = 0;
			}
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, textureManager : ITextureManager) : void
		{
			super.activate(view, context, canvasModel, textureManager);
		}
		
		override protected function createBrushMesh() : IBrushMesh
		{
			return new SourceCopyMesh();
		}

		override public function set brushShape(brushShape : AbstractBrushShape) : void
		{
			super.brushShape = brushShape;
			SourceCopyMesh(_brushMesh).brushTexture = _brushShape.texture;
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			var strategy : FlatColorStrategy = new FlatColorStrategy();
			strategy.setBlendFactors(1,1);
			return strategy;
		}

		override protected function processPoint( point : SamplePoint) : void
		{
			var uvScale:Number = 1 / _canvasModel.textureWidth;
				
			var rsize : Number = _maxBrushRenderSize * rng.getMappedNumber(point.size * 0.5, point.size, Quad.easeInOut);
			if (rsize > _maxBrushRenderSize) rsize = _maxBrushRenderSize;
			else if (rsize < _minBrushRenderSize) rsize = _minBrushRenderSize;
			
			var uvBounds:Rectangle = appendVO.uvBounds;
			uvBounds.x = int(rng.getNumber(0,shapeVariations[0])) * shapeVariations[2];
			uvBounds.y = int(rng.getNumber(0,shapeVariations[1])) * shapeVariations[3];
			
			var baseAngle:Number = Math.atan2(uvBounds.height,uvBounds.width);
			var halfSize : Number = rsize * _canvasScaleW*.5;
			var rotationBrush:Number = point.angle;
			var cos1 : Number =   halfSize*Math.cos(baseAngle + rotationBrush);
			var sin1 : Number =  -halfSize*Math.sin(baseAngle + rotationBrush);
			var cos2 : Number =   halfSize*Math.cos(- baseAngle + rotationBrush);
			var sin2 : Number =  -halfSize*Math.sin( -baseAngle + rotationBrush);
			
			halfSize = rsize * rng.getNumber( 0.9,1.1)*.5 * uvScale;
			var rotationSource:Number = point.angle;
			var cos1s : Number =   halfSize*Math.cos(baseAngle + rotationSource);
			var sin1s : Number =  -halfSize*Math.sin(baseAngle + rotationSource);
			var cos2s : Number =   halfSize*Math.cos(- baseAngle + rotationSource);
			var sin2s : Number =  -halfSize*Math.sin( -baseAngle + rotationSource);
			
			var xBrush:Number = point.normalX;
			var yBrush:Number = point.normalY;
			var brushAngle:Number =  point.angle + rng.getNumber( -0.05, 0.05 ) * Math.PI;
			var xSource:Number = 0.5 * (point.normalX + 1) + Math.cos(brushAngle) * point.size * uvScale;
			var ySource:Number = 0.5 * (-point.normalY + 1) + Math.sin(brushAngle) * point.size * uvScale;
			
			var data:Vector.<Number> = appendVO.verticesAndUV;
			data[0] = xBrush - cos1;
			data[1] = yBrush - sin1;
			data[2] = uvBounds.left;
			data[3] = uvBounds.top;
			data[4] = (xSource - cos1s) ;
			data[5] = (ySource - sin1s);
			
			data[6] = xBrush + cos2;
			data[7] = yBrush + sin2;
			data[8] = uvBounds.right;
			data[9] = uvBounds.top;
			data[10] = (xSource + cos2s);
			data[11] = (ySource + sin2s);
			
			data[12] = xBrush + cos1;
			data[13] = yBrush + sin1;
			data[14] = uvBounds.right;
			data[15] = uvBounds.bottom;
			data[16] = (xSource + cos1s);
			data[17] = (ySource + sin1s);
			
			data[18] = xBrush - cos2;
			data[19] = yBrush - sin2;
			data[20] = uvBounds.left;
			data[21] = uvBounds.bottom;
			data[22] = (xSource - cos2s);
			data[23] = (ySource - sin2s);
			
			appendVO.point = point;
			_brushMesh.append( appendVO );
			
			/*
			var angleOut:Number = Math.random() * Math.PI * 2;
			var radiusOut:Number = 10 + Math.random() * 100;
			var angleIn:Number = angleOut + ( Math.random()  - Math.random() ) * 0.05;
			var radiusIn:Number = radiusOut * (0.9 + 0.2 * Math.random());
			var offsetX:Number = 5 * ( Math.random()  - Math.random() );
			var offsetY:Number = 5 * ( Math.random()  - Math.random() );
			
			
			_vertexUVData[0] = (x + radiusOut * Math.cos(angleOut)) * _canvasScaleW - 1;
			_vertexUVData[1] = -((y + radiusOut * Math.sin(angleOut))  * _canvasScaleH - 1);
			_vertexUVData[2]=  (x + offsetX + radiusIn * Math.cos(angleIn)) / _canvasModel.width;
			_vertexUVData[3]=  (y + offsetY + radiusIn * Math.sin(angleIn)) / _canvasModel.height;
			
			angleOut += Math.PI * 60 / 180;
			angleIn += Math.PI * 60 / 180;
			_vertexUVData[4] = (x + radiusOut * Math.cos(angleOut)) * _canvasScaleW - 1;
			_vertexUVData[5] = -((y + radiusOut * Math.sin(angleOut))  * _canvasScaleH - 1);
			_vertexUVData[6]=  (x + offsetX + radiusIn * Math.cos(angleIn)) / _canvasModel.width;
			_vertexUVData[7]=  (y + offsetY + radiusIn * Math.sin(angleIn)) / _canvasModel.height;
			
			angleOut += Math.PI * 60 / 180;
			angleIn += Math.PI * 60 / 180;
			_vertexUVData[8] = (x + radiusOut * Math.cos(angleOut)) * _canvasScaleW - 1;
			_vertexUVData[9] = -((y + radiusOut * Math.sin(angleOut))  * _canvasScaleH - 1);
			_vertexUVData[10]=  (x + offsetX + radiusIn * Math.cos(angleIn)) / _canvasModel.width;
			_vertexUVData[11]=  (y + offsetY + radiusIn * Math.sin(angleIn)) / _canvasModel.height;
			
			_tempStroke.appendTriangle(_vertexUVData,null);
			*/
		}
		
		
	}
}
