package net.psykosoft.psykopaint2.core.views.popups.share.util
{

import com.milkmangames.nativeextensions.events.GVFacebookEvent;

import flash.display.BitmapData;

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;

public class FacebookSharer extends SharerBase
{
	private var _shareBmd:BitmapData;

	public function FacebookSharer(manager:SocialSharingManager) {
		super(manager);
	}

	override public function share(content:Array):void {
	    super.share(content);

		_shareBmd = _contentToBeShared[0];

		var loggedIn:Boolean = _manager.checkLoggedInFacebook();
		if(loggedIn) {
			doShareFacebook();
		}
		else {
			// Log in.
			trace("FacebookSharer - logging in...");
			_manager.addEventListener(GVFacebookEvent.FB_LOGGED_IN, onFaceBookLoggedInEvent);
			_manager.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFaceBookLogInFailedEvent);
			_manager.loginFacebook();
		}
	}

	private function onFaceBookLoggedInEvent(event:GVFacebookEvent):void {
		trace("FacebookSharer - logged in.");
		_manager.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, onFaceBookLoggedInEvent);
		_manager.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFaceBookLogInFailedEvent);
		doShareFacebook();
	}

	private function onFaceBookLogInFailedEvent(event:GVFacebookEvent):void {
		trace("FacebookSharer - failed to log in.");
		_manager.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, onFaceBookLoggedInEvent);
		_manager.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFaceBookLogInFailedEvent);
		failedSignal.dispatch();
	}

	private function doShareFacebook():void {
		trace("FacebookSharer - posting...");
		_manager.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFaceBookRequestResponseEvent);
		_manager.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onFaceBookRequestFailedEvent);
		_manager.postPhotoFacebook(_shareBmd);
	}

	private function onFaceBookRequestFailedEvent( event:GVFacebookEvent ):void {
		trace("FacebookSharer - Post failed.");
		_manager.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFaceBookRequestResponseEvent);
		_manager.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onFaceBookRequestFailedEvent);
		failedSignal.dispatch();
	}

	private function onFaceBookRequestResponseEvent( event:GVFacebookEvent ):void {
		trace("FacebookSharer - Posted.");
		_manager.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFaceBookRequestResponseEvent);
		_manager.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onFaceBookRequestFailedEvent);
		completedSignal.dispatch();
	}
}
}
