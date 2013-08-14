package net.psykosoft.psykopaint2.book.commands
{
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestBookRootViewRemovalSignal;

	public class DestroyBookModuleCommand
	{
		[Inject]
		public var notifyBookModuleDestroyedSignal : NotifyBookModuleDestroyedSignal;

		[Inject]
		public var requestBookRootViewRemovalSignal : RequestBookRootViewRemovalSignal;

		public function execute() : void
		{
			requestBookRootViewRemovalSignal.dispatch();
			notifyBookModuleDestroyedSignal.dispatch();
		}
	}
}
