package net.psykosoft.psykopaint2.core.errors
{
	public class AbstractMethodError extends Error
	{
		public function AbstractMethodError()
		{
			super("Abstract method called");
		}
	}
}
