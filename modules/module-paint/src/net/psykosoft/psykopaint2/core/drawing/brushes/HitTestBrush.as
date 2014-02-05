package net.psykosoft.psykopaint2.core.drawing.brushes
{
	import com.quasimondo.geom.Circle;
	import com.quasimondo.geom.LinearMesh;
	import com.quasimondo.geom.LinearPath;
	import com.quasimondo.geom.MixedPath;
	import com.quasimondo.geom.MixedPathPoint;
	import com.quasimondo.geom.PeuckerSimplification;
	import com.quasimondo.geom.Polygon;
	import com.quasimondo.geom.Triangle;
	import com.quasimondo.geom.Vector2;
	import com.quasimondo.geom.WhyattSimplification;
	import com.quasimondo.geom.utils.PolygonUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.IColorStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.color.PyramidMapIntrinsicsStrategy;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.AbstractBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.RenderTextureBrushShape;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.DrawingApiMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.IBrushMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureMorphingSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TextureSplatMesh;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedAntialiasedColoredTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.TexturedTriangleStroke;
	import net.psykosoft.psykopaint2.core.drawing.data.DelaunayMetaData;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	
	public class HitTestBrush extends AbstractBrush
	{

		private var circle:Circle;
		private var shpHolder:Sprite;
		private var previewShp:Shape;
		private var shp1:Shape;
		private var shp2:Shape;
		private var shp3:Shape;
		private var opacity:Number;
		private var drawMatrix:Matrix;
		private var fillMatrix:Matrix;
		private var hitMap:BitmapData;
		private var hitMap2:BitmapData;
		private const origin:Point = new Point();
		private var lastFillColor:int;
		private var fillRect:Rectangle;
		private var testTexture:BitmapData;
		[Embed( source = "shapes/assets/paper_seamless.png", mimeType="image/png")]
		protected var SourceImage : Class;
		private var _pathSmoothing:PsykoParameter;
		
		public function HitTestBrush()
		{
			super(true);
			type = BrushType.BLOB;
			
			_shininess.numberValue = .3;
			_glossiness.numberValue = .25;
			_bumpiness.numberValue = .6;
			
			_appendVO.verticesAndUV = new Vector.<Number>(36,true);
			_appendVO.point = new SamplePoint();
			_appendVO.point.colorsRGBA[3] = _appendVO.point.colorsRGBA[7] = _appendVO.point.colorsRGBA[11] = 1;
			previewShp = new Shape();
			shpHolder = new Sprite();
			shp1 = new Shape();
			shp2 = new Shape();
			shp3 = new Shape();
			shp1.alpha = 0.25;
			shp1.blendMode = "normal";
			shp3.blendMode = "multiply";
			shpHolder.addChild(shp1);
			shpHolder.addChild(shp2);
			shpHolder.addChild(shp3);
			shp1.filters = [ new BlurFilter(16,16,2)];
			
			fillRect = new Rectangle();
			drawMatrix = new Matrix();
			fillMatrix = new Matrix();
			//x,y,u,v,d1,d2,d3,unused
			for ( var i:int = 0; i < 36; i++ )
			{
				_appendVO.verticesAndUV[i] = 0;
			}
			testTexture = (new SourceImage() as Bitmap).bitmapData;
			
			
		}

		override public function activate(view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer:CanvasRenderer, paintSettingsModel : UserPaintSettingsModel) : void
		{
			super.activate(view, context, canvasModel, renderer, paintSettingsModel);
			if (_brushShape)
				assignBrushShape();
			if ( !hitMap )
			{
				hitMap = new TrackedBitmapData(_canvasModel.width,_canvasModel.height,true,0);
				hitMap2 = new TrackedBitmapData(_canvasModel.width,_canvasModel.height,true,0);
			} else {
				hitMap.fillRect(hitMap.rect,0);
				
			}
		}

		override protected function createBrushMesh() : IBrushMesh
		{
			return new DrawingApiMesh()
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
			DrawingApiMesh(_brushMesh).brushTexture = _brushShape.texture;
			DrawingApiMesh(_brushMesh).normalTexture = _brushShape.normalSpecularMap;
			_pathManager.brushAngleRange = brushShape.rotationRange;
		}

		override protected function createColorStrategy() : IColorStrategy
		{
			return new PyramidMapIntrinsicsStrategy(_canvasModel);
		}
		
		override protected function onPathStart() : void
		{
			super.onPathStart();
			circle = null; 
			previewShp.graphics.clear();
			
			_view.stage.quality = StageQuality.HIGH;
			
			
			hitMap2.fillRect(hitMap2.rect,0);
			
			(_view as Sprite).addChild(previewShp);
			previewShp.scaleX = 1 / _pathManager.canvasScaleX;
			previewShp.scaleY = 1 / _pathManager.canvasScaleY; 
			previewShp.x = -_pathManager.canvasOffsetX / _pathManager.canvasScaleX;
			previewShp.y = -_pathManager.canvasOffsetY / _pathManager.canvasScaleY; 
		}
		
		override  protected function onPathPoints(points : Vector.<SamplePoint>) : void
		{
			var len : uint = points.length;
			if ( len == 0 ) return;
			
			if ( _firstPoint )
			{
				if ( hitMap.getPixel32( points[0].x,points[0].y ) != 0 ) return;
				circle = new Circle( points[0].x,points[0].y, 1 );
				opacity = points[0].colorsRGBA[3];
			}
			var lastR:Number = circle.r;
			if ( len > 1 )
			{
				circle.r = Math.sqrt( Math.pow(circle.c.x - points[len-1].x,2)+ Math.pow(circle.c.y - points[len-1].y,2));
			}
			
			
			var colors:Vector.<Number> = points[0].colorsRGBA;
			var fillColor:int;
			
			if ( circle.r > lastR )
			{
				
				_colorStrategy.getColor(circle.c.x,circle.c.y,circle.r*2,colors,1);
				fillColor = (int(0xff * colors[0]) << 16) | (int(0xff * colors[1]) << 8) | int(0xff * colors[2]);
				
				previewShp.graphics.clear();
				previewShp.graphics.beginFill(fillColor);
				circle.draw(previewShp.graphics);
				previewShp.graphics.endFill();
				hitMap2.draw( previewShp );
				if ( hitMap2.hitTest(origin,1,hitMap,origin,1 ))
				{
					fillRect.width = fillRect.height = circle.r * 2 + 2;
					fillRect.x = circle.c.x - circle.r - 1;
					fillRect.y = circle.c.y - circle.r - 1;
					hitMap2.fillRect(fillRect,0);
					
					var maxR:Number =  circle.r;
					for ( var r:Number = lastR + 1; r < maxR; r++ )
					{
						circle.r = r;
						_colorStrategy.getColor(circle.c.x,circle.c.y,circle.r*2,colors,1);
						fillColor = (int(0xff * colors[0]) << 16) | (int(0xff * colors[1]) << 8) | int(0xff * colors[2]);
						
						previewShp.graphics.clear();
						previewShp.graphics.beginFill(fillColor);
						circle.draw(previewShp.graphics);
						previewShp.graphics.endFill();
						hitMap2.draw( previewShp );
						if ( hitMap2.hitTest(origin,1,hitMap,origin,1 ))
						{
							circle.r = r -1;
							break;
						}
					}
				}
			} else {
				_colorStrategy.getColor(circle.c.x,circle.c.y,circle.r*2,colors,1);
				fillColor = (int(0xff * colors[0]) << 16) | (int(0xff * colors[1]) << 8) | int(0xff * colors[2]);
				
				previewShp.graphics.clear();
				previewShp.graphics.beginFill(fillColor);
				circle.draw(previewShp.graphics);
				previewShp.graphics.endFill();
			}
			
			fillRect.width = fillRect.height = circle.r * 2 + 2;
			fillRect.x = circle.c.x - circle.r - 1;
			fillRect.y = circle.c.y - circle.r - 1;
			hitMap2.fillRect(fillRect,0);
			if ( _firstPoint )
			{
				_firstPoint = false;
				dispatchEvent(new Event(STROKE_STARTED));
			} 
		}

		
		override protected function onPathEnd() : void
		{
			(_view as Sprite).removeChild(previewShp);
			var g1:Graphics = shp1.graphics;
			var g2:Graphics = shp2.graphics;
			var g3:Graphics = shp3.graphics;
			g1.clear();
			g1.lineStyle();
			g2.clear();
			g2.lineStyle();
			g3.clear();
			g3.lineStyle();
			
			if ( circle != null )
			{
			 	hitMap.draw(previewShp);
				var colors:Vector.<Number> = _appendVO.point.colorsRGBA;
				
				fillMatrix.identity();
				fillMatrix.rotate( (Math.random()-Math.random())*Math.PI*0.5);
				fillMatrix.translate(Math.random()*1024,Math.random()*1024);
					
				g2.beginBitmapFill(testTexture,fillMatrix,true,true);
				circle.draw(g2);
				g2.endFill();
					
				_colorStrategy.getColor(circle.c.x,circle.c.y,circle.r * 2,colors,1);
				g3.beginFill((int(0xff * colors[0]) << 16) | (int(0xff * colors[1]) << 8) | int(0xff * colors[2]),opacity);
				circle.draw(g3);
				g3.endFill();
					
				g1.beginFill(0x000000);
				circle.draw(g1);
				g1.endFill();
				
					
					
				var bds:Rectangle = shpHolder.getBounds(shpHolder);
				bds.x -= 8;
				bds.y -= 8;
				bds.width += 16;
				bds.height += 16;
				var bm:BitmapData = (_brushShape as RenderTextureBrushShape)._brushMap;
				drawMatrix.tx = -bds.x + 1;
				drawMatrix.ty = -bds.y + 1;
				_appendVO.diagonalAngle = Math.atan2(bds.height,bds.width);
				_appendVO.diagonalLength = Math.sqrt(bds.width*bds.width+bds.height*bds.height); 
				_appendVO.size = _canvasScaleW; 
				_appendVO.point.x = bds.x -1 + bds.width * 0.5
				_appendVO.point.y = bds.y -1 + bds.height * 0.5;
				_appendVO.point.normalizeXY(_canvasScaleW,_canvasScaleH);
				_appendVO.uvBounds.width  = (bds.width + 1) / _brushShape.size;
				_appendVO.uvBounds.height = (bds.height +1) / _brushShape.size;
				
					
				bds.x = bds.y = 0;
				bds.width += 2;
				bds.height += 2;
				bm.fillRect(bds,0);
				bm.drawWithQuality(shpHolder,drawMatrix,null,"normal",null,true,StageQuality.HIGH);
				//bm.drawWithQuality(shp1,drawMatrix,null,"normal",null,true,StageQuality.HIGH);
				//bm.drawWithQuality(shp2,drawMatrix,null,"multiply",null,true,StageQuality.HIGH);
				_brushShape.update(false);
				
				
				
				_brushMesh.append(_appendVO);
			}		
				invalidateRender();
			
			setTimeout(super.onPathEnd,1);
		}
		override protected function onPickColor( point : SamplePoint, pickRadius : Number, smoothFactor : Number ) : void
		{
			
		}

		
		override protected function processPoint( point : SamplePoint) : void
		{
		}
	}
}
