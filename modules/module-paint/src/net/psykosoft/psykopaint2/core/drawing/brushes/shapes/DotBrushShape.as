package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class DotBrushShape extends AbstractBrushShape
	{
		public function DotBrushShape(context3D : Context3D)
		{
			super(context3D, "dot", 1,8);
			_rotationRange = 0;
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, false,0xff000000);
			shp.graphics.beginFill(0xffffff);
			shp.graphics.drawCircle(size * 0.5,size * 0.5,size * 0.2);
			shp.graphics.endFill();
			var scaleTransform:Matrix = new Matrix(); 
			var mipLevel:int = 0; 
			while ( size > 0 ) { 
				bitmapData.fillRect(bitmapData.rect,0xff000000);
				bitmapData.drawWithQuality(shp,scaleTransform,null,"normal",null,true,StageQuality.HIGH_8X8_LINEAR );
				texture.uploadFromBitmapData(bitmapData,mipLevel);
				scaleTransform.scale( 0.5, 0.5 ); 
				mipLevel++; 
				size >>= 1; 
				
			}
			bitmapData.dispose();
		}
		
		override protected function uploadNormalSpecularMap(texture : Texture) : void
		{
			//TEMPORARY:
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, false,0xff000000);
			shp.graphics.beginFill(0xffffff);
			shp.graphics.drawCircle(size * 0.5,size * 0.5,size * 0.2);
			shp.graphics.endFill();
			var scaleTransform:Matrix = new Matrix(); 
			var mipLevel:int = 0; 
			while ( size > 0 ) { 
				bitmapData.fillRect(bitmapData.rect,0xff000000);
				bitmapData.drawWithQuality(shp,scaleTransform,null,"normal",null,true,StageQuality.HIGH_8X8_LINEAR );
				texture.uploadFromBitmapData(bitmapData,mipLevel);
				scaleTransform.scale( 0.5, 0.5 ); 
				mipLevel++; 
				size >>= 1; 
				
			}
			bitmapData.dispose();
		}
	}
}
