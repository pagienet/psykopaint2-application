package net.psykosoft.psykopaint2.core.views.popups.notifications
{
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class NotificationSettingsViewMediator extends MediatorBase
	{
		[Inject]
		public var view:NotificationSettingsView;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		public function NotificationSettingsViewMediator()
		{
		}

		override public function initialize():void
		{
			super.initialize();
			registerView(view);
			view.popUpWantsToCloseSignal.add(onRequestClose);
		}

		override public function destroy():void
		{
			super.destroy();
			view.popUpWantsToCloseSignal.remove(onRequestClose);
		}

		private function onRequestClose():void
		{
			requestHidePopUpSignal.dispatch();
		}
	}
}