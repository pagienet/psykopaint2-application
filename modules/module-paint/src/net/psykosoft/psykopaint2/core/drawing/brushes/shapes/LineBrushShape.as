package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class LineBrushShape extends AbstractBrushShape
	{
		[Embed(source="assets/lines2.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/lines2_height.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function LineBrushShape(context3D : Context3D)
		{
			super(context3D, "line", 1);
			rotationRange = 0;
			
			_variationFactors[0] = 1; // cols
			_variationFactors[1] = 8; // rows
			_variationFactors[2] = 1 / _variationFactors[0];
			_variationFactors[3] = 1 / _variationFactors[1];
			_variationFactors[4] = Math.atan2(_variationFactors[3],_variationFactors[2]);
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			
			var source:BitmapData = new SourceMap().bitmapData;
			
			uploadMips(_textureSize, source, texture);
			
			source.dispose();
			/*
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new BitmapData(size, size, false,0xff000000);
			shp.graphics.lineStyle(0,0xffffff);
			shp.graphics.moveTo(2,int(size * 0.5));
			shp.graphics.lineTo(int(size * 0.5),int(size * 0.5));
			
			
			var scaleTransform:Matrix = new Matrix(); 
			var mipLevel:int = 0; 
			while ( size > 0 ) { 
				bitmapData.fillRect(bitmapData.rect,0xff000000);
				bitmapData.drawWithQuality(shp,scaleTransform,null,"normal",null,true,StageQuality.HIGH );
				texture.uploadFromBitmapData(bitmapData,mipLevel);
				scaleTransform.scale( 0.5, 0.5 ); 
				mipLevel++; 
				size >>= 1; 
				
			}
			bitmapData.dispose();
			*/
		}

		override protected function uploadNormalSpecularMap(texture : Texture) : void
		{
			var source:BitmapData = new SourceNormalSpecularMap().bitmapData;

			uploadMips(_textureSize, source, texture);

			source.dispose();
		}


	}
}
