package net.psykosoft.psykopaint2.book.views.models
{
	public class BookData
	{
		public var index : uint;
		public var pageIndex : uint;
		public var inPageIndex : uint;
		public var queueID:String;

		//debug
		private var _originalFilename:String = "";

		public function set originalFilename(val :String):void
		{
			var splited:Array = val.split("/");
			_originalFilename = splited[splited.length-1];
		}

		public function get originalFilename():String
		{
			return _originalFilename;
		}

		public function BookData(index : uint, pageIndex : uint, inPageIndex : uint)
		{
			this.index = index;
			this.pageIndex = pageIndex;
			this.inPageIndex = inPageIndex;
		}
	}
}
