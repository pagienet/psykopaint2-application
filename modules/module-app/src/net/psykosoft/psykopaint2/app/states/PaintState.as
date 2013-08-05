package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;

	use namespace ns_state_machine;

	public class PaintState extends State
	{
		public function PaintState()
		{
		}

		override ns_state_machine function activate(data : Object = null) : void
		{

		}

		override ns_state_machine function deactivate() : void
		{
		}
	}
}
