package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class BasicCircularShape extends AbstractBrushShape
	{
		public function BasicCircularShape(context3D : Context3D)
		{
			super(context3D, "basic circular", 512);
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, true, 0x00000000);
			shp.graphics.beginFill(0xffffff);

			//tiny padding to allow for antialiasing:
			var half : int = size *.5;
			shp.graphics.drawCircle(half, half, half-1);
			shp.graphics.endFill();
			var scaleTransform:Matrix = new Matrix();
			var mipLevel:int = 0;
			while ( size > 0 ) {
				bitmapData.fillRect(bitmapData.rect,0x00000000);
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
