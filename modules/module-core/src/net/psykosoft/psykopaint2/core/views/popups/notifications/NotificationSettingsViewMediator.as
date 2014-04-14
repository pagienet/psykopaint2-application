package net.psykosoft.psykopaint2.core.views.popups.notifications
{
	import net.psykosoft.psykopaint2.core.services.PushNotificationService;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class NotificationSettingsViewMediator extends MediatorBase
	{
		[Inject]
		public var view:NotificationSettingsView;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		[Inject]
		public var pushNotificationService : PushNotificationService;

		public function NotificationSettingsViewMediator()
		{
		}

		override public function initialize():void
		{
			super.initialize();
			registerView(view);
			pushNotificationService.subscriptionFailed.add(onSubscriptionFailed);
			view.popUpWantsToCloseSignal.add(onRequestClose);
			view.settingsChangedSignal.add(onSettingsChanged);
			view.checkbox.selected = pushNotificationService.isSubscribed;
		}

		override public function destroy():void
		{
			super.destroy();
			pushNotificationService.subscriptionFailed.remove(onSubscriptionFailed);
			view.popUpWantsToCloseSignal.remove(onRequestClose);
			view.settingsChangedSignal.remove(onSettingsChanged);
		}

		private function onSettingsChanged():void
		{
			if (view.checkbox.selected)
				pushNotificationService.subscribe();
			else
				pushNotificationService.unsubscribe();
		}

		private function onSubscriptionFailed():void
		{
			view.checkbox.selected = false;
		}

		private function onRequestClose():void
		{
			requestHidePopUpSignal.dispatch();
		}
	}
}
