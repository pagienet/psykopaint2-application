package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import com.quasimondo.geom.BoundingCircle;
	import com.quasimondo.geom.Polygon;
	import com.quasimondo.geom.Triangle;
	import com.quasimondo.geom.Vector2;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class AntialiasedTriangleBrushShape extends AbstractBrushShape
	{
		public function AntialiasedTriangleBrushShape(context3D : Context3D)
		{
			super(context3D, "triangle", 1);
			this.size = 512;
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, true,0);
			
			
			//var noiseMap:BitmapData = new TrackedBitmapData(size,size,false,0);
			//noiseMap.noise(12346,200,255,1,true);
			
			var scaleTransform:Matrix = new Matrix(); 
			var tmpMap:BitmapData = bitmapData.clone();
			
			var mipLevel:int = 0; 
			while ( size > 0 ) { 
				var c:Vector2 =  new Vector2(size*0.5,size*0.5);
				var t:Polygon = Triangle.getCenteredTriangle(c,100,100,100,Math.PI * ( 12.5 / 180) ).toPolygon();
				var s:Number = (size - size / 32) / ( t.getBoundingCircle( BoundingCircle.BOUNDINGCIRCLE_EXACT).r * 2);
				t.scale( s, s, c );
				t = t.getOffsetPolygon(-2);
			//	shp.graphics.beginBitmapFill(noiseMap);
				shp.graphics.beginFill(0xffffff);
				t.draw( shp.graphics );
				shp.graphics.endFill();
				
				bitmapData.fillRect(bitmapData.rect,0);
				bitmapData.drawWithQuality(shp,null,null,"normal",null,true,StageQuality.BEST );
				texture.uploadFromBitmapData(bitmapData,mipLevel);
				//scaleTransform.scale( 0.5, 0.5 ); 
				mipLevel++; 
				size >>= 1; 
				
			}
			tmpMap.dispose();
			bitmapData.dispose();
		}
	}
}
