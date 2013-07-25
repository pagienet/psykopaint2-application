package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;

	public class HomeState extends State
	{
		[Inject]
		public var requestNavigationToggleSignal : RequestNavigationToggleSignal;

		[Inject]
		public var requestHomeViewScrollSignal : RequestHomeViewScrollSignal;

		public function HomeState()
		{
		}

		override public function activate() : void
		{
			// TODO: this probably needs to be moved to homeModule.activate()
			requestNavigationToggleSignal.dispatch(1, 0.5);
			requestHomeViewScrollSignal.dispatch(1);
		}

		override public function deactivate() : void
		{
		}
	}
}
