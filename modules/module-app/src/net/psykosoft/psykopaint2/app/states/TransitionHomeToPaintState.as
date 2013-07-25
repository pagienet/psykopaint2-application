package net.psykosoft.psykopaint2.app.states
{
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal_OLD_TO_REMOVE;

	use namespace ns_state_machine;

	public class TransitionHomeToPaintState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestStateChangeSignal_OLD_TO_REMOVE;

		public function TransitionHomeToPaintState()
		{
		}

		override ns_state_machine function activate() : void
		{
			// todo: remove state change signals, replace by proper signals
			requestStateChangeSignal.dispatch(StateType.PREPARE_FOR_PAINT_MODE);

			// oh this timeout is evil :s
			setTimeout(function () : void
			{
				requestStateChangeSignal.dispatch(StateType.TRANSITION_TO_PAINT_MODE);
			}, 50);
		}

		override ns_state_machine function deactivate() : void
		{
		}
	}
}
