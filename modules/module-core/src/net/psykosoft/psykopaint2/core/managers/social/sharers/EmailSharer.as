package net.psykosoft.psykopaint2.core.managers.social.sharers
{

import com.milkmangames.nativeextensions.events.GVMailEvent;

import flash.display.BitmapData;

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;

public class EmailSharer extends SharerBase
{
	public function EmailSharer(manager:SocialSharingManager) {
		super(manager);
	}

	override public function share(content:Array):void {
		super.share( content );

		trace("EmailSharer - quickshare()");

		var bmd:BitmapData = _contentToBeShared[0];

		_manager.goViral.addEventListener(GVMailEvent.MAIL_SENT, onMailSent);
		_manager.goViral.addEventListener(GVMailEvent.MAIL_FAILED, onMailFailed);
		_manager.goViral.addEventListener(GVMailEvent.MAIL_SAVED, onMailSaved);
		_manager.goViral.addEventListener(GVMailEvent.MAIL_CANCELED, onMailCanceled);

		_manager.goViral.showEmailComposerWithBitmap("Check out what I did with Psykopaint!", "", "", false, bmd);
	}

	private function cleanUpListeners():void {
		_manager.goViral.removeEventListener(GVMailEvent.MAIL_SENT, onMailSent);
		_manager.goViral.removeEventListener(GVMailEvent.MAIL_FAILED, onMailFailed);
		_manager.goViral.removeEventListener(GVMailEvent.MAIL_SAVED, onMailSaved);
		_manager.goViral.removeEventListener(GVMailEvent.MAIL_CANCELED, onMailCanceled);
	}

	private function onMailCanceled( event:GVMailEvent ):void {
		trace("EmailSharer - canceled.");
		cleanUpListeners();
		abortedSignal.dispatch();
	}

	private function onMailSaved( event:GVMailEvent ):void {
		trace("EmailSharer - saved but not sent.");
		cleanUpListeners();
		abortedSignal.dispatch();
	}

	private function onMailFailed( event:GVMailEvent ):void {
		trace("EmailSharer - failed.");
		cleanUpListeners();
		failedSignal.dispatch();
	}

	private function onMailSent( event:GVMailEvent ):void {
		trace("EmailSharer - sent.");
		cleanUpListeners();
		completedSignal.dispatch();
	}
}
}
