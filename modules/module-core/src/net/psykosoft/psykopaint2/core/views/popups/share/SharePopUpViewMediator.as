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

		// Nothing to wait for, close.
		if(!shareFacebook && !shareTwitter) {
			requestHidePopUpSignal.dispatch();
		}
	}

	private function doShareFacebook():void {
		if(_shareFacebook && _shareBmd) {
			trace("sharing on facebook...");
			socialSharingManager.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFaceBookRequestResponseEvent);
			socialSharingManager.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onFaceBookRequestFailedEvent);
			socialSharingManager.postPhotoFacebook(_shareBmd);
		}
	}

	private function onFaceBookRequestFailedEvent( event:GVFacebookEvent ):void {
		trace("FB post failed.");
		socialSharingManager.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFaceBookRequestResponseEvent);
		socialSharingManager.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onFaceBookRequestFailedEvent);
		requestHidePopUpSignal.dispatch();
	}

	private function onFaceBookRequestResponseEvent( event:GVFacebookEvent ):void {
		trace("FB post success.");
		socialSharingManager.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFaceBookRequestResponseEvent);
		socialSharingManager.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onFaceBookRequestFailedEvent);
		requestHidePopUpSignal.dispatch();
	}

	private function onFaceBookLoggedInEvent(event:GVFacebookEvent):void {
		doShareFacebook();
		socialSharingManager.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, onFaceBookLoggedInEvent);
		socialSharingManager.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFaceBookLogInFailedEvent);
	}

	private function onFaceBookLogInFailedEvent(event:GVFacebookEvent):void {
		// TODO
		socialSharingManager.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, onFaceBookLoggedInEvent);
		socialSharingManager.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFaceBookLogInFailedEvent);
	}

	private function onPopUpWantsToClose():void {
		requestHidePopUpSignal.dispatch();
	}
}
}
