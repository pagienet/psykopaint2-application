package net.psykosoft.psykopaint2.home.commands.load
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewSceneReadySignal;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;

	public class InitializeHomeModuleViewsCommand extends AsyncCommand
	{
		[Inject]
		public var requestAddViewToMainLayerSignal:RequestAddViewToMainLayerSignal;

		[Inject]
		public var notifyHomeViewSceneReadySignal:NotifyHomeViewSceneReadySignal;

		private var _homeRootView:HomeRootView;

		override public function execute():void {

			trace( this, "execute()" );

			notifyHomeViewSceneReadySignal.addOnce( onHomeViewsReady );
			_homeRootView = new HomeRootView();
			requestAddViewToMainLayerSignal.dispatch( _homeRootView );
		}

		private function onHomeViewsReady():void {
			dispatchComplete( true );
		}
	}
}
