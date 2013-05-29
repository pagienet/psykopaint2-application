package net.psykosoft.psykopaint2.core.utils
{
	public class EmbedUtils
	{
		public static function StringFromEmbed(embeddedClass : Class) : String
		{
			return new embeddedClass().toString();
		}
	}
}
