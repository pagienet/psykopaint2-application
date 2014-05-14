package net.psykosoft.psykopaint2.core.views.popups.quickshare
{

import net.psykosoft.psykopaint2.base.utils.alert.Alert;
import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;
import net.psykosoft.psykopaint2.core.managers.social.sharers.CompositeSharer;
import net.psykosoft.psykopaint2.core.managers.social.sharers.FacebookSharer;
import net.psykosoft.psykopaint2.core.managers.social.sharers.TwitterSharer;
import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

public class QuickSharePopUpViewMediator extends MediatorBase
{
	[Inject]
	public var view:QuickSharePopUpView;

	[Inject]
	public var requestHidePopUpSignal:RequestHidePopUpSignal;

	[Inject]
	public var socialSharingManager:SocialSharingManager;

	private var _sharer:CompositeSharer;

	override public function initialize():void {
		super.initialize();

		registerView( view );
		manageStateChanges = false;
		manageMemoryWarnings = false;

		_sharer = new CompositeSharer(socialSharingManager);
		_sharer.completedSignal.add(onUtilCompleted);

		// From app.
		// ...

		// From view.
		view.popUpWantsToCloseSignal.add( onPopUpWantsToClose );
		view.popUpWantsToShareSignal.add( onPopUpWantsToShare );
	}

	override public function destroy():void {
		super.destroy();
		if(view.bmd) view.bmd.dispose();
		_sharer.completedSignal.remove(onUtilCompleted);
		_sharer.dispose();
		view.popUpWantsToCloseSignal.remove( onPopUpWantsToClose );
	}

	private function onPopUpWantsToShare():void {

		if(view.facebookChk.selected) _sharer.addSharer(new FacebookSharer(socialSharingManager));
		if(view.twitterChk.selected) _sharer.addSharer(new TwitterSharer(socialSharingManager));

		// Nothing to wait for, close.
		if(_sharer.numSharers == 0) exitPopUp();
		else _sharer.share([view.tf.text, view.bmd]);
	}

	private function onUtilCompleted():void {
		exitPopUp();
	}

	private function exitPopUp():void {

		// Feedback on errors.
		if(_sharer.numSharers > 0) {
			if( _sharer.failedSharerNames.length == _sharer.numSharers ) {
				Alert.show( "Oops! We couldn't post to any of the services you selected." );
			}
			else if( _sharer.failedSharerNames.length > 0 ) {
				var failedStr:String = _sharer.failedSharerNames.join( ", " );
				Alert.show( "Oops! We couldn't post to the services " + failedStr + ", but the rest worked." );
			} // No alert if everything went ok.
		}

		requestHidePopUpSignal.dispatch();
	}

	private function onPopUpWantsToClose():void {
		requestHidePopUpSignal.dispatch();
	}
}
}
