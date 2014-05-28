package net.psykosoft.psykopaint2.core.data
{

	import flash.display.BitmapData;
	import flash.net.ObjectEncoding;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;

	public class PaintingDataDeserializer
	{
		public function PaintingDataDeserializer()
		{
		}

		public function deserializeDPP(bytes : TrackedByteArray) : PaintingDataVO
		{
			var paintingDataVO : PaintingDataVO = new PaintingDataVO();
			
			if (bytes.readUTF() != "DPP2")
				throw "Incorrect file type";
			
			// TODO: Make backwards compatible
			if (bytes.readUTF() != PaintingFileUtils.PAINTING_FILE_VERSION)
				throw "Incorrect file version";
			
			// Read dimensions.
			paintingDataVO.width = bytes.readInt();
			paintingDataVO.height = bytes.readInt();
			
			trace( this, "width: " + paintingDataVO.width + ", height: " + paintingDataVO.height );
			
			var isPhotoPainting : Boolean = bytes.readBoolean();
			trace( this, "isPhotoPainting",isPhotoPainting );
			var hasColorBackgroundOriginal : Boolean = bytes.readBoolean();
			trace( this, "hasColorBackgroundOriginal",hasColorBackgroundOriginal );
			
			paintingDataVO.colorPalettes = PaintingFileUtils.readColorPalettes(bytes);
			
			// Read painting surfaces.
			paintingDataVO.colorData = PaintingFileUtils.decodeImage(bytes, paintingDataVO.width, paintingDataVO.height);
			paintingDataVO.normalSpecularData = PaintingFileUtils.decodeImage(bytes, paintingDataVO.width, paintingDataVO.height);
			var surfaceNormalSpecularDataBytes : TrackedByteArray = PaintingFileUtils.decodeImage(bytes, paintingDataVO.width, paintingDataVO.height);
			
			//MATHIEU: THIS IS WHERE WE NEED TO FETCH THE ID OF THE SURFACE INSTEAD OF THE BITMAPDATA
			//TODO
			paintingDataVO.surfaceNormalSpecularData = new BitmapData(paintingDataVO.width, paintingDataVO.height, false);
			paintingDataVO.surfaceNormalSpecularData.setPixels(paintingDataVO.surfaceNormalSpecularData.rect, surfaceNormalSpecularDataBytes);
			surfaceNormalSpecularDataBytes.clear();
			
			if (isPhotoPainting)
			{
				paintingDataVO.sourceImageData = PaintingFileUtils.decodeImage(bytes, paintingDataVO.width, paintingDataVO.height);
			}
			if (hasColorBackgroundOriginal)
			{
				paintingDataVO.colorBackgroundOriginal = PaintingFileUtils.decodeImage(bytes, paintingDataVO.width, paintingDataVO.height);
			}
			
			//Hopefully this is okay to do here:
			bytes.clear();
			
			return paintingDataVO;
		}
		
		
		public function deserializePPP(bytes : TrackedByteArray) : PaintingDataVO
		{
			var pppfileData : PPPFileData = new PPPFileData();
			
		
			var fileBytes : ByteArray = bytes;
			//fileBytes.uncompress(CompressionAlgorithm.DEFLATE);
			fileBytes.objectEncoding = ObjectEncoding.AMF3;
			registerClassAlias("net.psykosoft.psykopaint2.core.data.PPPFileData", PPPFileData);
			pppfileData = PPPFileData(fileBytes.readObject()) ;
			
			//CONVERT PPP FILE TO PAINTING DATA VO
			var paintingDataVO : PaintingDataVO = new PaintingDataVO();
			// NO NEEDED paintingDataVO.version= pppfileData.version;
			paintingDataVO.colorData = pppfileData.colorData;
			paintingDataVO.normalSpecularData= pppfileData.normalSpecularData;
			paintingDataVO.sourceImageData= pppfileData.sourceImageData;
			paintingDataVO.surfaceNormalSpecularData= pppfileData.surfaceNormalSpecularData;
			paintingDataVO.colorBackgroundOriginal = pppfileData.colorBackgroundOriginal;
			paintingDataVO.surfaceID= pppfileData.surfaceID;
			paintingDataVO.width= pppfileData.width;
			paintingDataVO.height= pppfileData.height;
			paintingDataVO.loadedFileName= pppfileData.loadedFileName;
			
			//AMF3 doesn't undertand vectors. So we have to convert from array to vector
			paintingDataVO.colorPalettes = new Vector.<Vector.<uint>>();
			for (var i:int = 0; i < pppfileData.colorPalettes.length; i++) 
			{
				paintingDataVO.colorPalettes.push(pppfileData.colorPalettes[i]);
			}
			paintingDataVO.isPhotoPainting = pppfileData.isPhotoPainting;
			
			//NO NEED FOR YOU ANYMORE LITTLE GUY, GO GET GARBAGE COLLECTED:
			pppfileData = null;
			
			return paintingDataVO;
		}

	}
}
