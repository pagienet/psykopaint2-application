package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import com.quasimondo.delaunay.BoundingTriangleNodeProperties;
	import com.quasimondo.delaunay.Delaunay;
	import com.quasimondo.delaunay.DelaunayEdge;
	import com.quasimondo.delaunay.DelaunayTriangle;
	import com.quasimondo.geom.Circle;
	import com.quasimondo.geom.Triangle;
	import com.quasimondo.geom.Vector2;
	
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import de.popforge.math.LCG;
	
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapTdsiStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedAntialiasedColoredTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedColoredTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.data.DelaunayMetaData;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.resources.ITextureManager;

	public class DelaunayBrush extends SplatBrushBase
	{
		private var rng:LCG;
		private var delaunay:Delaunay;
		//private var _vertexUVData:Vector.<Number>;
		
		public function DelaunayBrush()
		{
			super(true);
			rng = new LCG( Math.random() * 0xffffff );
			type = BrushType.DELAUNAY;
			delaunay = new Delaunay();
			appendVO.verticesAndUV = new Vector.<Number>(24,true);
			
			//x,y,u,v,d1,d2,d3,unused
			for ( var i:int = 0; i < 24; i++ )
			{
				appendVO.verticesAndUV[i] = 0;
			}

			
			//appendVO.colorsRGBA.length = 12; // since we have triangles there are only 3 color spots
			//appendVO.colorsRGBA[3] = appendVO.colorsRGBA[7] = appendVO.colorsRGBA[11] = 1;
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer:CanvasRenderer) : void
		{
			super.activate(view, context, canvasModel,renderer);
			pathManager.callbacks.onPickColor = null;
			
			delaunay.createBoundingTriangle(canvasModel.width * 0.5,canvasModel.height * 0.5 );
			var btnp:BoundingTriangleNodeProperties = new BoundingTriangleNodeProperties();
			for ( var i:int = -100; i <canvasModel.width+100; i+=100 )
			{
				delaunay.insertXY(i,-100, btnp);
				delaunay.insertXY(i,canvasModel.height+100,btnp);
			}
			for (  i = -100; i <canvasModel.height+100; i+=100 )
			{
				delaunay.insertXY(-100,i, btnp);
				delaunay.insertXY(canvasModel.width+100,i, btnp);
			}
		
			
		}
		
		override protected function createBrushMesh() : IBrushMesh
		{
			return  new TexturedAntialiasedColoredTriangleStroke();
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
		
		override protected function onPickColor( point : SamplePoint, pickRadius:Number, smoothFactor:Number ) : void
		{
			
		}

		override protected function processPoint( point : SamplePoint) : void
		{
			var meta:DelaunayMetaData = new DelaunayMetaData( point.angle );
			var attempts:int = 10;
			var success:Boolean = delaunay.insertXY(point.x,point.y,meta );
			while ( !success && attempts-- > 0 )
			{
				success = delaunay.insertXY(point.x + rng.getNumber(-5,5),point.y + rng.getNumber(-5,5), meta );
			}

			renderDelaunay( point );
		}
		
		
		private function renderDelaunay( point : SamplePoint ):void
		{
			var edge:DelaunayEdge = delaunay.edges.elementAt(0);
			var overdrive:Number = 1.2;
			var rendered:Dictionary = new Dictionary();
			var overlap:Number = 1;
			var colors:Vector.<Number> = point.colorsRGBA;
			var vertexUVData:Vector.<Number> = appendVO.verticesAndUV;
			
			while ( edge != null )
			{
				if ( edge.changed )
				{
					edge.changed  = false;
					var triangle:DelaunayTriangle = edge.inT;
					if ( ((triangle.edge.p1.data is BoundingTriangleNodeProperties) ||
						   (triangle.edge.nextE.p2.data is BoundingTriangleNodeProperties)|| 
						   (triangle.edge.p2.data is BoundingTriangleNodeProperties)) ) rendered[triangle] = true;
					
					if ( rendered[triangle] == null)
					{
						
						var cx:Number = triangle.c_cx;
						var cy:Number = triangle.c_cy;
						var size:Number = triangle.c_r;
						if ( size == -1 )
						{
							size = triangle.c_r = Math.sqrt(triangle.c_r2);
						}
						size *=0.005;
						
						_colorStrategy.getColor(cx,cy,size,colors,1);
						var luma:Number = 0.29900 * colors[0] +  0.58700 * colors[1] + 0.11400 * colors[2] ;
						var r:Number = colors[0];
						var g:Number = colors[1];
						var b:Number = colors[2];
						
						
						var tri:Triangle = triangle.toTriangle();
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
						if (triangle.edge.p1.data is DelaunayMetaData ) angle = DelaunayMetaData(triangle.edge.p1.data).angle;
						else if (triangle.edge.nextE.p2.data is DelaunayMetaData ) angle = DelaunayMetaData(triangle.edge.nextE.p2.data).angle;
						else if (triangle.edge.p2.data is DelaunayMetaData ) angle = DelaunayMetaData(triangle.edge.p2.data).angle;
						
						tri.rotate( angle, tri_c);
						
						scale = _brushShape.size / (bounds.r*2) * rng.getNumber( 1- _sizeFactor.lowerRangeValue, 1-_sizeFactor.upperRangeValue );
						tri.scale(scale,scale,tri_c);
						
						vertexUVData[2] = 0.5 + (tri.p1.x - tri_c.x) * _canvasScaleW;
						vertexUVData[3] = 0.5 - (tri.p1.y - tri_c.y) * _canvasScaleH;
						vertexUVData[10] = 0.5 + (tri.p2.x - tri_c.x) * _canvasScaleW;
						vertexUVData[11] = 0.5 - (tri.p2.y - tri_c.y) * _canvasScaleH;
						vertexUVData[18] = 0.5 + (tri.p3.x - tri_c.x) * _canvasScaleW;
						vertexUVData[19] = 0.5 - (tri.p3.y - tri_c.y) * _canvasScaleH;
						
						
						_colorStrategy.getColor((0.8 * cx + 0.2 * x1),(0.8 * cy + 0.2 * y1),size,colors,1);
						var dl:Number =  overdrive * ((0.29900 * colors[0] +  0.58700 * colors[1] + 0.11400 * colors[2]) - luma);
						colors[0] = r + dl;
						colors[1] = g + dl;
						colors[2] = b + dl;
						
						_colorStrategy.getColor((0.8 * cx + 0.2 * x2),(0.8 * cy + 0.2 * y2),size,colors,2);
						dl =  overdrive * ((0.29900 * colors[4] +  0.58700 * colors[5] + 0.11400 * colors[6] ) - luma);
						colors[4] = r + dl;
						colors[5] = g + dl;
						colors[6] = b + dl;
						
						_colorStrategy.getColor((0.8 * cx + 0.2 * x2),(0.8 * cy + 0.2 * y2),size,colors,4);
						dl =  overdrive * ((0.29900 * colors[8] +  0.58700 * colors[9] + 0.11400 * colors[10] ) - luma);
						colors[8] = r + dl;
						colors[9] = g + dl;
						colors[10] = b + dl;
						appendVO.point = point;
						
						_brushMesh.append( appendVO );
						rendered[triangle] = true;
					}
				}
				edge = edge.next;
			}
		}

		
		
	}
}
