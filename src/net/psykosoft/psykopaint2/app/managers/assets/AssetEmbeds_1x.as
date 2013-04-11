package net.psykosoft.psykopaint2.app.managers.assets
{
	public class AssetEmbeds_1x
	{
		///////////////////////////////ASSETS////////////////////////////////
		//[Embed(source="/../assets/images/PsykopaintLogo500x230.jpg")]
		//public static var PsykopaintLogo500x230Texture:Class;
		
		
		///////////////////////////////SRPITE SHEETS////////////////////////////////
		[Embed(source="/../assets-packaged/interface/footer/footer-sd.png")]
		public static var footerAtlasTexture:Class;
		
		[Embed(source="/../assets-packaged/interface/footer/footer-sd.xml" , mimeType="application/octet-stream")]
		public static var footerAtlasXml:Class;
		
		[Embed(source="/../assets-packaged/interface/uiComponents/uiComponents-sd.png")]
		public static var uiComponentsAtlasTexture:Class;
		
		[Embed(source="/../assets-packaged/interface/uiComponents/uiComponents-sd.xml" , mimeType="application/octet-stream")]
		public static var uiComponentsAtlasXml:Class;
		
		
		///////////////////////////////FONTS////////////////////////////////
		[Embed(source="/../assets-packaged/interface/fonts/profont/profomac.gif")]
		public static var profontTexture:Class;
		
		[Embed(source="/../assets-packaged/interface/fonts/profont/PROFONT.FON" , mimeType="application/octet-stream")]
		public static var profontXML:Class;
		
		public static var PROFONT:String = "profont";
		
		
	}
}