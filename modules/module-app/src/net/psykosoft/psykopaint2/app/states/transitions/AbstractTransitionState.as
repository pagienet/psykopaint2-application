package net.psykosoft.psykopaint2.app.states.transitions
{
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowController;
	
	use namespace ns_state_machine;

	
	public class AbstractTransitionState extends State
	{
		
		
		public function AbstractTransitionState()
		{
			super();
		}
		
		override ns_state_machine function activate(data : Object = null) : void
		{
			super.activate(data);
			//ALWAYS DEACTIVATE GESTURES DURING TRANSITION
			GestureManager.gesturesEnabled=false;
			GrabThrowController.gesturesEnabled=false;
			trace("DEACTIVATE GESTURES DURING TRANSITION "+this);
		}
		
		override ns_state_machine function deactivate() : void
		{
			super.deactivate();
			
		}
		
	}
}