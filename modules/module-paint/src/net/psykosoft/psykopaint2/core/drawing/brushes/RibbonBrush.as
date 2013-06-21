package net.psykosoft.psykopaint2.core.drawing.brushes
{

	import com.quasimondo.geom.Circle;
	import com.quasimondo.geom.Triangle;
	import com.quasimondo.geom.Vector2;

	import de.popforge.math.LCG;

	import flash.display.DisplayObject;
	import flash.display3D.Context3D;

	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedAntialiasedColoredTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.resources.ITextureManager;

	public class RibbonBrush extends SplatBrushBase
	{
		private var rng:LCG;
		
		
		public function RibbonBrush()
		{
			super(true);
			rng = new LCG( Math.random() * 0xffffff );
			type = BrushType.RIBBON;
			
			appendVO.verticesAndUV = new Vector.<Number>(24,true);
			
			//x,y,u,v,d1,d2,d3,unused
			for ( var i:int = 0; i < 24; i++ )
			{
				appendVO.verticesAndUV[i] = 0;
			}

			
			//appendVO.colorsRGBA.length = 12; // since we have triangles there are only 3 color spots
			//appendVO.colorsRGBA[3] = appendVO.colorsRGBA[7] = appendVO.colorsRGBA[11] = 1;
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel) : void
		{
			super.activate(view, context, canvasModel);
			pathManager.callbacks.onPickColor = null;
		}
		
		override protected function createBrushMesh() : IBrushMesh
		{
			return new TexturedAntialiasedColoredTriangleStroke();
		}
		
		override protected function set brushShape(brushShape : AbstractBrushShape) : void
		{
			super.brushShape = brushShape;
			TexturedAntialiasedColoredTriangleStroke(_brushMesh).brushTexture = _brushShape.texture;
			TexturedAntialiasedColoredTriangleStroke(_brushMesh).normalTexture = _brushShape.normalSpecularMap;
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			var strategy : PyramidMapTdsiStrategy = new PyramidMapTdsiStrategy(_canvasModel);
			//strategy.setBlendFactors(1,1);
			return strategy;
		}
		
		

		override protected function processPoint( point : SamplePoint) : void
		{
			if ( point.speed <= 0 ) return;
			
			var overdrive:Number = 1.2;
			var overlap:Number = 1;
			var vertexUVData:Vector.<Number> = appendVO.verticesAndUV;
			
			
			
				
			var tri:Triangle = new Triangle( 
				new Vector2(point.x + Math.cos(point.angle) * point.speed * 0.5, point.y + Math.sin(point.angle) * point.speed * 0.5),
				new Vector2(point.x - Math.cos(point.angle) * point.speed * 0.5, point.y - Math.sin(point.angle) * point.speed* 0.5),
				new Vector2(point.x + Math.cos(point.angle + Math.PI * 0.5) * point.speed, point.y + Math.sin(point.angle+ Math.PI * 0.5) * point.speed)
				
			);
			
			
			var inc:Circle = tri.inCircle;
			var scale:Number = (inc.r + 0.6) / inc.r;
			tri.scale( scale, scale, inc.c );
			
			var x1:Number = tri.p1.x;
			var y1:Number = tri.p1.y ;
			var x2:Number = tri.p2.x;
			var y2:Number = tri.p2.y;
			var x3:Number = tri.p3.x;
			var y3:Number = tri.p3.y;
			
			
			vertexUVData[0] = x1 * _canvasScaleW - 1.0;
			vertexUVData[1] = -(y1 * _canvasScaleH - 1.0);
			vertexUVData[8] = x2 * _canvasScaleW - 1.0;
			vertexUVData[9] = -(y2 * _canvasScaleH - 1.0);
			vertexUVData[16] = x3 * _canvasScaleW - 1.0;
			vertexUVData[17] = -(y3 * _canvasScaleH - 1.0);
			
			
			var l1:Number = tri.p1.distanceToLine( tri.p2, tri.p3 );
			var l2:Number = tri.p2.distanceToLine( tri.p1, tri.p3 );
			var l3:Number = tri.p3.distanceToLine( tri.p1, tri.p2 );
			
			vertexUVData[4]  =  l1;
			vertexUVData[13] =  l2;
			vertexUVData[22] =  l3;
			
			
			var bounds:Circle = tri.getBoundingCircle();
			var tri_c:Vector2 = bounds.c;
			var angle:Number = 0;
			
			tri.rotate( angle, tri_c);
			
			scale = _brushShape.size / (bounds.r*2) * rng.getNumber( 1- _sizeFactor.lowerRangeValue, 1-_sizeFactor.upperRangeValue );
			tri.scale(scale,scale,tri_c);
			
			vertexUVData[2] = 0.5 + (tri.p1.x - tri_c.x) * _canvasScaleW;
			vertexUVData[3] = 0.5 - (tri.p1.y - tri_c.y) * _canvasScaleH;
			vertexUVData[10] = 0.5 + (tri.p2.x - tri_c.x) * _canvasScaleW;
			vertexUVData[11] = 0.5 - (tri.p2.y - tri_c.y) * _canvasScaleH;
			vertexUVData[18] = 0.5 + (tri.p3.x - tri_c.x) * _canvasScaleW;
			vertexUVData[19] = 0.5 - (tri.p3.y - tri_c.y) * _canvasScaleH;
			
			
			
			appendVO.point = point;
			
			_brushMesh.append( appendVO );
			
				
		}
	}
}
