package net.psykosoft.psykopaint2.core.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;

	public class InitDisplayCommand extends AsyncCommand
	{
		override public function execute():void {

			trace( this, "execute()" );

			var coreRootView:CoreRootView = new CoreRootView();
			CoreSettings.DISPLAY_ROOT.addChild( coreRootView );

//			coreRootView.runUiTests();
			coreRootView.allViewsReadySignal.addOnce( onViewsReady );
			coreRootView.initialize();
		}

		private function onViewsReady():void {
			dispatchComplete( true );
		}
	}
}
