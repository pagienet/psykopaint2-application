package net.psykosoft.psykopaint2.home.commands.unload
{

	import net.psykosoft.psykopaint2.core.signals.RequestNavigationDisposalSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeRootViewRemovalSignal;

	import robotlegs.bender.bundles.mvcs.Command;

	public class RemoveHomeModuleDisplayCommand extends Command
	{
		[Inject]
		public var requestNavigationDisposalSignal:RequestNavigationDisposalSignal;

		[Inject]
		public var requestHomeRootViewRemovalSignal:RequestHomeRootViewRemovalSignal;

		override public function execute():void {

			trace( this, "execute()" );

			// Dispose all sub-navigation instances currently cached in SbNavigationView.
			requestNavigationDisposalSignal.dispatch();

			// Dispose home root view.
			requestHomeRootViewRemovalSignal.dispatch();
		}
	}
}
