package net.psykosoft.psykopaint2.app.managers.assets
{
	public class Fonts
	{
		
		// Don't skip the "embedAsCFF"-part!
		[Embed(source="/../assets-src/interface/fonts/Lorem Ipsum.ttf", embedAsCFF="false", fontFamily="Lorem Ipsum")]
		private static const LoremIpsumFont:Class;
		public static const LoremIpsum:String = "Lorem Ipsum";
		
		
		[Embed(source="/../assets-src/interface/fonts/warugaki.otf", embedAsCFF="false", fontFamily="Warugaki")]
		private static const WarugakiFont:Class;
		public static const Warugaki:String = "Warugaki";
		
		
	}
}