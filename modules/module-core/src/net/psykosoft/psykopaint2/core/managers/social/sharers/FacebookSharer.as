package net.psykosoft.psykopaint2.core.managers.social.sharers
{

import com.milkmangames.nativeextensions.GoViral;
import com.milkmangames.nativeextensions.events.GVFacebookEvent;

import flash.display.BitmapData;

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;

public class FacebookSharer extends SharerBase
{
	private var _shareMsg:String;
	private var _shareBmd:BitmapData;

	public function FacebookSharer(manager:SocialSharingManager) {
		super(manager);
	}

	override public function share(content:Array):void {
	    super.share(content);

		trace("FacebookSharer - share()");
		_sharerName = "Facebook";

		if(!GoViral.isSupported()) {
			failedSignal.dispatch();
			return;
		}

		_shareMsg = _contentToBeShared[0];
		_shareBmd = _contentToBeShared[1];

		if(_manager.goViral.isFacebookAuthenticated()) {
			doShareFacebook();
		}
		else {
			// Log in.
			trace("FacebookSharer - logging in...");
			_manager.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN, onFaceBookLoggedInEvent);
			_manager.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFaceBookLogInFailedEvent);
			_manager.goViral.authenticateWithFacebook( "user_likes, user_photos" );
		}
	}

	private function doShareFacebook():void {
		trace("FacebookSharer - posting...");
		_manager.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFaceBookRequestResponseEvent);
		_manager.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onFaceBookRequestFailedEvent);
		_manager.goViral.facebookPostPhoto(_shareMsg, _shareBmd);
	}

	private function onFaceBookLoggedInEvent(event:GVFacebookEvent):void {
		trace("FacebookSharer - logged in.");
		_manager.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, onFaceBookLoggedInEvent);
		_manager.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFaceBookLogInFailedEvent);
		doShareFacebook();
	}

	private function onFaceBookLogInFailedEvent(event:GVFacebookEvent):void {
		trace("FacebookSharer - failed to log in.");
		_manager.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, onFaceBookLoggedInEvent);
		_manager.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFaceBookLogInFailedEvent);
		failedSignal.dispatch();
	}

	private function onFaceBookRequestFailedEvent( event:GVFacebookEvent ):void {
		trace("FacebookSharer - Post failed.");
		_manager.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFaceBookRequestResponseEvent);
		_manager.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onFaceBookRequestFailedEvent);
		failedSignal.dispatch();
	}

	private function onFaceBookRequestResponseEvent( event:GVFacebookEvent ):void {
		trace("FacebookSharer - Posted.");
		_manager.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFaceBookRequestResponseEvent);
		_manager.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onFaceBookRequestFailedEvent);
		completedSignal.dispatch();
	}
	
	override public function dispose():void{
		super.dispose();
		_shareMsg = null;
		_shareBmd.dispose();
		_shareBmd = null;
	}
}
}
