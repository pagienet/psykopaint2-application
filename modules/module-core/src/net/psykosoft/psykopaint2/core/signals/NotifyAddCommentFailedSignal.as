package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyAddCommentFailedSignal extends Signal
	{
		public function NotifyAddCommentFailedSignal()
		{
			super(uint);	// any value of AMFErrorCode
		}
	}
}
