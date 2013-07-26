package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.home.HomeModule;

	use namespace ns_state_machine;

	public class SplashScreenState extends State
	{
		private var _coreModule : CoreModule;

		public function SplashScreenState(coreModule : CoreModule)
		{
			_coreModule = coreModule;
		}

		override ns_state_machine function activate() : void
		{
		}

		override ns_state_machine function deactivate() : void
		{
			_coreModule.coreRootView.removeSplashScreen();
		}
	}
}
