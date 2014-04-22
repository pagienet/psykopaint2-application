package net.psykosoft.psykopaint2.core.views.popups.notifications
{
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NotificationSubscriptionType;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class NotificationSettingsViewMediator extends MediatorBase
	{
		[Inject]
		public var view:NotificationSettingsView;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		[Inject]
		public var loggedInUserProxy : LoggedInUserProxy;

		public function NotificationSettingsViewMediator()
		{
		}

		override public function initialize():void
		{
			super.initialize();
			registerView(view);
			loggedInUserProxy.onChange.add(onUserChange);
			view.popUpWantsToCloseSignal.add(onRequestClose);
			view.settingsChangedSignal.add(onSettingsChanged);
			updateUI();
		}

		override public function destroy():void
		{
			super.destroy();
			loggedInUserProxy.onChange.remove(onUserChange);
			view.popUpWantsToCloseSignal.remove(onRequestClose);
			view.settingsChangedSignal.remove(onSettingsChanged);
		}

		private function onUserChange():void
		{
			updateUI();
		}

		private function onSettingsChanged(type : int, value : Boolean):void
		{
			enableUI(false);
			loggedInUserProxy.subscribeNotification(type, value, onSubscriptionSuccess, onSubscriptionFailed);
		}

		private function onSubscriptionSuccess():void
		{
			enableUI(true);
		}

		private function enableUI(value : Boolean):void
		{
			view.likesCheckbox.enabled = value;
			view.newsCheckbox.enabled = value;
		}

		private function onSubscriptionFailed():void
		{
			updateUI();
		}

		private function updateUI():void
		{
			view.likesCheckbox.selected = loggedInUserProxy.hasNotificationSubscription(NotificationSubscriptionType.FAVORITE_PAINTING);
			view.newsCheckbox.selected = loggedInUserProxy.hasNotificationSubscription(NotificationSubscriptionType.GLOBAL_NEWS);
		}

		private function onRequestClose():void
		{
			requestHidePopUpSignal.dispatch();
		}
	}
}
