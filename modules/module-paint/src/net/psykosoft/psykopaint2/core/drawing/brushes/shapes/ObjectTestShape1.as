package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.resources.TextureProxy;

	public class ObjectTestShape1 extends AbstractBrushShape
	{
		[Embed(source="assets/TestObjects.png", mimeType="image/png")]
		protected var SourceImage:Class;
		
		protected var uvColorData:Vector.<int>;
		
		public function ObjectTestShape1(context3D : Context3D)
		{
			super(context3D, "objects", 1);
			
			_variationFactors[0] = 4;
			_variationFactors[1] = 3;
			_variationFactors[2] = 1 / _variationFactors[0];
			_variationFactors[3] = 1 / _variationFactors[1];
			
			var source:BitmapData = (new SourceImage() as Bitmap ).bitmapData;
			this.size = source.width;
			
			rotationRange = 0.2;
			
			uvColorData = Vector.<int>([ 79,152,104,158,85,160,87,212,119,199,117,125,112,131,115,132,167,107,134,120,124,128,128,128
									]);
			
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
		
		override public function getClosestColorMatchYUV( color:Vector.<Number>, targetRect:Rectangle, mismatchProbability:Number = 0, YUVWeights:Vector.<Number> = null):void
		{
			if ( YUVWeights == null ) YUVWeights = _YUVWeights;
			var y:int = 76.245 * color[0] + 149.685 * color[1] + 29.07 * color[2];
			var u:int = -43.0287 * color[0] -84.4713 * color[1] + 127.5 * color[2] + 128.5;
			var v:int = 127.5 * color[0] -106.76595 * color[1] -20.73405 * color[2] + 128.5;
			var ud:int, vd:int, yd:int, sd:int;
			var bestSd:int = YUVWeights[0] * (yd = y - uvColorData[0]) * vd + YUVWeights[1] * (ud = u - uvColorData[1]) * ud + YUVWeights[2] * (vd = v - uvColorData[2]) * vd ;
			var bestI:int = 0;
			for ( var i:int = 3; i < uvColorData.length; i+=3 )
			{
				sd = YUVWeights[0] * (yd = y - uvColorData[i]) * yd + 
					YUVWeights[1] * (ud = u - uvColorData[i+1]) * ud + 
					YUVWeights[2] * (vd = v - uvColorData[i+2]) * vd;
				
				var check:Boolean = Math.random() > mismatchProbability;
				if ( (!check  && sd < bestSd) || (check  && sd >= bestSd)  )
				{
					bestSd = sd;
					bestI = i;
				}
			}
			
			bestI /= 3;
			targetRect.x = _variationFactors[2] * (bestI % _variationFactors[0]);
			targetRect.y = _variationFactors[3] * int(bestI / _variationFactors[0]);
			targetRect.width  = _variationFactors[2];
			targetRect.height = _variationFactors[3];
		}

	}
}
