package net.psykosoft.psykopaint2.home.commands.load
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;

	public class AddHomeModuleDisplayCommand extends AsyncCommand
	{
		[Inject]
		public var requestAddViewToMainLayerSignal:RequestAddViewToMainLayerSignal;

		private var _homeRootView:HomeRootView;

		override public function execute():void {

			trace( this, "execute()" );

			_homeRootView = new HomeRootView();
			_homeRootView.onSubViewsReady.add( onSubViewRead );
			requestAddViewToMainLayerSignal.dispatch( _homeRootView );
		}

		private function onSubViewRead():void {
			_homeRootView.onSubViewsReady.remove( onSubViewRead );
			dispatchComplete( true );
		}
	}
}
