package net.psykosoft.psykopaint2.core.configuration
{
	import flash.text.TextFormat;

	public class PsykoFonts
	{
		public static var BookFont:LoveYaLikeASisterSolid = new LoveYaLikeASisterSolid();
		
		public static function get BookFontSmall():TextFormat
		{
			return new TextFormat("Love Ya Like A Sister Solid",10,0);
		}
		
	}
}