package net.psykosoft.psykopaint2.app.states
{
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.app.signals.RequestCreateCanvasBackgroundSignal;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleCommand;

	use namespace ns_state_machine;

	public class TransitionHomeToPaintState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestStateChangeSignal_OLD_TO_REMOVE;

		[Inject]
		public var requestCreateCanvasBackgroundSignal : RequestCreateCanvasBackgroundSignal;

		[Inject]
		public var requestSetupPaintModuleSignal : RequestSetupPaintModuleCommand;


		public function TransitionHomeToPaintState()
		{
		}

		override ns_state_machine function activate() : void
		{
			requestCreateCanvasBackgroundSignal.dispatch();

			// todo: remove state change signals, replace by proper signals
			// this is only to switch views
			requestStateChangeSignal.dispatch(StateType.PREPARE_FOR_PAINT_MODE);

			// TODO: move this to paint activation state
			requestSetupPaintModuleSignal.dispatch();

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
