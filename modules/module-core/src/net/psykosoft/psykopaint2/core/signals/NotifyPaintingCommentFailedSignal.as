package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyPaintingCommentFailedSignal extends Signal
	{
		public function NotifyPaintingCommentFailedSignal()
		{
			super(uint);	// status code of AMFErrorCode
		}
	}
}
