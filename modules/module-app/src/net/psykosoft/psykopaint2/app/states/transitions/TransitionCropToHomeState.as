package net.psykosoft.psykopaint2.app.states.transitions
{
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;

	public class TransitionCropToHomeState extends AbstractTransitionState
	{
		[Inject]
		public var requestDestroyCropModuleSignal : RequestDestroyCropModuleSignal;

		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

		[Inject]
		public var notifyHomeModuleSetUpSignal : NotifyHomeModuleSetUpSignal;

		public var homeState : State;

		public function TransitionCropToHomeState()
		{
		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			use namespace ns_state_machine;
			super.activate(data);
			requestStateChangeSignal.dispatch(NavigationStateType.PICK_IMAGE);
			stateMachine.setActiveState(homeState);
		}

		override ns_state_machine function deactivate() : void
		{
			use namespace ns_state_machine;
			super.deactivate();
			requestDestroyCropModuleSignal.dispatch();
		}
	}
}
