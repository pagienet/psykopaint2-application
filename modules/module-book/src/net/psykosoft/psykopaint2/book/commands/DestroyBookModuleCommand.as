package net.psykosoft.psykopaint2.book.commands
{

	import net.psykosoft.psykopaint2.book.signals.RequestBookRootViewRemovalSignal;

	import robotlegs.bender.bundles.mvcs.Command;

	public class DestroyBookModuleCommand extends Command
	{
		[Inject]
		public var requestBookRootViewRemovalSignal : RequestBookRootViewRemovalSignal;

		override public function execute() : void
		{
			requestBookRootViewRemovalSignal.dispatch();
		}

	}
}
