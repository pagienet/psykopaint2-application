package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class InkDotShape1 extends AbstractBrushShape
	{
		[Embed(source="assets/InkDots1.png", mimeType="image/png")]
		protected var SourceImage:Class;
		
		protected var uvColorData:Vector.<int>;
		
		public function InkDotShape1(context3D : Context3D)
		{
			super(context3D, "inkdots1", 1);
			
			_variationFactors[0] = 4; //cols
			_variationFactors[1] = 4; //rows
			_variationFactors[2] = 1 / _variationFactors[0];
			_variationFactors[3] = 1 / _variationFactors[1];
			
			var source:BitmapData = (new SourceImage() as Bitmap ).bitmapData;
			this.size = source.width;
			
			uvColorData = Vector.<int>([235,55,137,193,68,139,217,56,152,188,44,171,165,103,71,184,73,102,172,81,185,146,99,202,159,138,117,208,108,138,178,106,151,146,140,179,164,168,63,129,192,97,167,168,111,165,153,147]);
			
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size:int = _textureSize;
			var bitmapData : BitmapData = new BitmapData(size, size, true,0x00);
			var source:BitmapData = (new SourceImage() as Bitmap ).bitmapData;
			
			var scaleTransform:Matrix = new Matrix(size / source.width,0,0,size / source.width); 
			var mipLevel:int = 0; 
			while ( size > 0 ) { 
				bitmapData.fillRect(bitmapData.rect,0x00000000);
				//bitmapData.draw(source,scaleTransform,null,"normal",null,true);
				bitmapData.drawWithQuality(source,scaleTransform,null,"normal",null,true,StageQuality.BEST );
				texture.uploadFromBitmapData(bitmapData,mipLevel);
				scaleTransform.scale( 0.5, 0.5 ); 
				mipLevel++; 
				size >>= 1; 
				
			}
			_scaleFactor = Math.sqrt(Math.pow( _variationFactors[2],2) +  Math.pow( _variationFactors[3],2));
			bitmapData.dispose();
		}
		
		override protected function uploadHeightMap(texture : Texture) : void
		{
			var bitmapData : BitmapData = new BitmapData(size, size, true,0xff00007f);
			uploadMips(_textureSize, bitmapData, texture);
			bitmapData.dispose();
		}
		
		override public function getClosestColorMatchYUV( color:Vector.<Number>, targetRect:Rectangle, mismatchProbability:Number = 0, YUVWeights:Vector.<Number> = null):void
		{
			if ( YUVWeights == null ) YUVWeights = _YUVWeights;
			var y:int = 76.245 * color[0] + 149.685 * color[1] + 29.07 * color[2];
			var u:int = -43.0287 * color[0] -84.4713 * color[1] + 127.5 * color[2] + 128.5;
			var v:int = 127.5 * color[0] -106.76595 * color[1] -20.73405 * color[2] + 128.5;
			var ud:int, vd:int, yd:int, sd:int;
			
			var j:int = int(Math.random() * _variationFactors[0] * _variationFactors[1]) * 3;
			var bestSd:int = YUVWeights[0] * (yd = y - uvColorData[j]) * vd + YUVWeights[1] * (ud = u - uvColorData[j+1]) * ud + YUVWeights[2] * (vd = v - uvColorData[j+2]) * vd ;
			var bestJ:int = j;
			for ( var i:int = 3; i < uvColorData.length; i+=3 )
			{
				j = ( j + 3 ) % uvColorData.length;
				sd = YUVWeights[0] * (yd = y - uvColorData[j]) * yd + 
					 YUVWeights[1] * (ud = u - uvColorData[j+1]) * ud + 
					 YUVWeights[2] * (vd = v - uvColorData[j+2]) * vd;
				
				var check:Boolean = Math.random() < mismatchProbability;
				if ( (!check  && sd < bestSd) || check   )
				{
					bestSd = sd;
					bestJ = j;
				}
			}
			
			bestJ /= 3;
			targetRect.x = _variationFactors[2] * (bestJ % _variationFactors[0]);
			targetRect.y = _variationFactors[3] * int(bestJ / _variationFactors[0]);
			targetRect.width  = _variationFactors[2];
			targetRect.height = _variationFactors[3];
		}

	}
}
