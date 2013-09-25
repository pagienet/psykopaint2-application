package net.psykosoft.psykopaint2.home.commands.load
{

	import flash.utils.getTimer;
	
	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;
	
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.views.base.ViewLayerOrdering;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewSceneReadySignal;
	import net.psykosoft.psykopaint2.home.views.base.HomeRootView;

	public class InitializeHomeModuleViewsCommand extends AsyncCommand
	{
		[Inject]
		public var requestAddViewToMainLayerSignal:RequestAddViewToMainLayerSignal;

		[Inject]
		public var notifyHomeViewSceneReadySignal:NotifyHomeViewSceneReadySignal;

		private var _homeRootView:HomeRootView;
		private var _time:uint;

		override public function execute():void {

			trace( this, "execute()" );
			_time = getTimer();

			notifyHomeViewSceneReadySignal.addOnce( onHomeViewsReady );
			_homeRootView = new HomeRootView();
			requestAddViewToMainLayerSignal.dispatch( _homeRootView, ViewLayerOrdering.AT_BOTTOM_LAYER );
		}

		private function onHomeViewsReady():void {
			dispatchComplete( true );
			ConsoleView.instance.log( this, "done - " + String( getTimer() - _time ) );
		}
	}
}
