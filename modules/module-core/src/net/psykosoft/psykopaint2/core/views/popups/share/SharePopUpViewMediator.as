package net.psykosoft.psykopaint2.core.views.popups.share
{

import com.milkmangames.nativeextensions.events.GVFacebookEvent;

import flash.display.BitmapData;

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;
import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

public class SharePopUpViewMediator extends MediatorBase
{
	[Inject]
	public var view:SharePopUpView;

	[Inject]
	public var requestHidePopUpSignal:RequestHidePopUpSignal;

	[Inject]
	public var socialSharingManager:SocialSharingManager;

	override public function initialize():void {
		super.initialize();

		registerView( view );
		manageStateChanges = false;
		manageMemoryWarnings = false;

		// From app.
		// ...

		// From view.
		view.popUpWantsToCloseSignal.add( onPopUpWantsToClose );
		view.popUpWantsToShareSignal.add( onPopUpWantsToShare );
	}

	override public function destroy():void {
		super.destroy();
		if(_shareBmd) _shareBmd.dispose();
		view.popUpWantsToCloseSignal.remove( onPopUpWantsToClose );
	}

	private var _shareBmd:BitmapData;
	private var _shareFacebook:Boolean;
	private var _shareTwitter:Boolean;

	private function onPopUpWantsToShare(bmd:BitmapData, shareFacebook:Boolean, shareTwitter:Boolean):void {

		_shareFacebook = shareFacebook;
		_shareTwitter = shareTwitter;
		_shareBmd = bmd;

		if(shareFacebook) {
			var loggedIn:Boolean = socialSharingManager.checkLoggedInFacebook();
			trace("sharing on facebook - logged in: " + loggedIn);
			if(loggedIn) {
				doShareFacebook();
			}
			else {
				// Log in.
				socialSharingManager.addEventListener(GVFacebookEvent.FB_LOGGED_IN, onFaceBookLoggedInEvent);
				socialSharingManager.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFaceBookLogInFailedEvent);
				socialSharingManager.loginFacebook();
			}
		}

		if(shareTwitter) {
			// TODO
		}
	}

	private function doShareFacebook():void {
		if(_shareFacebook && _shareBmd) {
			trace("sharing on facebook");
		}
	}

	private function onFaceBookLoggedInEvent(event:GVFacebookEvent):void {
		doShareFacebook();
	}

	private function onFaceBookLogInFailedEvent(event:GVFacebookEvent):void {
		// TODO
	}

	private function onPopUpWantsToClose():void {
		requestHidePopUpSignal.dispatch();
	}
}
}
