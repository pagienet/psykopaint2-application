package net.psykosoft.psykopaint2.core.data
{

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.net.ObjectEncoding;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;

	public class PaintingDataDeserializer
	{
		public function PaintingDataDeserializer()
		{
		}

		public function deserializePPP(bytes : TrackedByteArray) : PaintingDataVO
		{
			var fileBytes : ByteArray = bytes;
			//fileBytes.uncompress(CompressionAlgorithm.DEFLATE);
			fileBytes.objectEncoding = ObjectEncoding.AMF3;
			registerClassAlias("net.psykosoft.psykopaint2.core.data.PPPFileData", PPPFileData);
			var pppfileData : PPPFileData = PPPFileData(fileBytes.readObject()) ;
			
			//CONVERT PPP FILE TO PAINTING DATA VO
			var paintingDataVO : PaintingDataVO = new PaintingDataVO();
			// NO NEEDED paintingDataVO.version= pppfileData.version;
			paintingDataVO.colorData = pppfileData.colorData;
			paintingDataVO.normalSpecularData = pppfileData.normalSpecularData;
			paintingDataVO.sourceImageData = pppfileData.sourceImageData;
			
			paintingDataVO.surfaceID = pppfileData.surfaceID;
			paintingDataVO.surfaceNormalSpecularData = new BitmapData(pppfileData.width,pppfileData.height,false);
			paintingDataVO.surfaceNormalSpecularData.setPixels(paintingDataVO.surfaceNormalSpecularData.rect, pppfileData.surfaceNormalSpecularData);

			if (pppfileData.colorBackgroundOriginal) {
				paintingDataVO.colorBackgroundOriginal = new BitmapData(1024, 768, false);
				paintingDataVO.colorBackgroundOriginal.setPixels(paintingDataVO.colorBackgroundOriginal.rect, pppfileData.colorBackgroundOriginal);
			}
			
			paintingDataVO.width= pppfileData.width;
			paintingDataVO.height= pppfileData.height;
			paintingDataVO.loadedFileName= pppfileData.loadedFileName;
			
			//AMF3 doesn't undertand vectors. So we have to convert from array to vector
			paintingDataVO.colorPalettes =new Vector.<Vector.<uint>>();
			for (var i:int = 0; i < pppfileData.colorPalettes.length; i++) 
			{
				paintingDataVO.colorPalettes[i] = new Vector.<uint>();
				for (var j:int = 0; j < pppfileData.colorPalettes[i].length; j++) 
				{
					paintingDataVO.colorPalettes[i][j] = pppfileData.colorPalettes[i][j];
				}
			}
			
			paintingDataVO.isPhotoPainting = pppfileData.isPhotoPainting;
			
			//NO NEED FOR YOU ANYMORE LITTLE GUY, GO GET GARBAGE COLLECTED:
			pppfileData = null;
			
			return paintingDataVO;
		}

	}
}
