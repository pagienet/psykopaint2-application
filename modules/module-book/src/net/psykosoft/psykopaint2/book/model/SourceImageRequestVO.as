package net.psykosoft.psykopaint2.book.model
{
	public class SourceImageRequestVO
	{
		public var bookImageSource : String;
		public var index : int;
		public var amount : int;

		public function SourceImageRequestVO(bookImageSource : String, index : int, amount : int)
		{
			this.bookImageSource = bookImageSource;
			this.index = index;
			this.amount = amount;
		}
	}
}
