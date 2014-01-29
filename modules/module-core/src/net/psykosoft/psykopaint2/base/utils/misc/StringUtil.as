package net.psykosoft.psykopaint2.base.utils.misc
{

	public class StringUtil
	{
		static public function replaceWordWith( text:String, wordToBeRemoved:String, wordTobeInserted:String ):String {
			var dump:Array = text.split(wordToBeRemoved);
			return dump[0] + wordTobeInserted + dump[1];
		}
	}
}
