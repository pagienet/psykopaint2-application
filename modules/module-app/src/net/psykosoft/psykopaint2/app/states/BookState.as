package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;

	public class BookState extends State
	{
		[Inject]
		public var requestStateChange : RequestNavigationStateChangeSignal;

		public function BookState()
		{
		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			requestStateChange.dispatch(NavigationStateType.BOOK);
		}

		override ns_state_machine function deactivate() : void
		{
		}
	}
}
