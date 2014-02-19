package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class BasicBrushShape extends AbstractBrushShape
	{
		[Embed(source="assets/basic_normalmap2.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function BasicBrushShape(context3D : Context3D)
		{
			super(context3D, "basic",64);
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, false,0xff000000);
			shp.graphics.beginFill(0xffffff);
			
			//tiny padding to allow for antialiasing:
			shp.graphics.drawRect(1,1, size-2, size-2);
			/*
			shp.graphics.moveTo(size * 0.5,2);
			shp.graphics.lineTo(size - 2,size * 0.5);
			shp.graphics.lineTo(size * 0.5,size-2);
			shp.graphics.lineTo(2,size * 0.5);
			*/
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
			//var source:BitmapData = new SourceNormalSpecularMap().bitmapData;
			var source:BitmapData = new BitmapData(size,size,false,0);
			source.noise(1234,0,64,3);
			uploadMips(_textureSize, source, texture);

			source.dispose();
		}
	}
}
