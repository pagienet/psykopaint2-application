package net.psykosoft.psykopaint2.core.views.popups.quickshare
{

import net.psykosoft.psykopaint2.base.utils.alert.Alert;
import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;
import net.psykosoft.psykopaint2.core.managers.social.sharers.CompositeSharer;
import net.psykosoft.psykopaint2.core.managers.social.sharers.FacebookSharer;
import net.psykosoft.psykopaint2.core.managers.social.sharers.TwitterSharer;
import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

public class QuickSharePopUpViewMediator extends MediatorBase
{
	[Inject]
	public var view:QuickSharePopUpView;

	[Inject]
	public var requestHidePopUpSignal:RequestHidePopUpSignal;
	
	[Inject]
	public var requestShowPopUpSignal:RequestShowPopUpSignal;
	
	[Inject]
	public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

	[Inject]
	public var socialSharingManager:SocialSharingManager;

	private var _sharer:CompositeSharer;

	override public function initialize():void {
		super.initialize();

		registerView( view );
		manageStateChanges = false;
		manageMemoryWarnings = false;

		_sharer = new CompositeSharer(socialSharingManager);

		// From app.
		// ...

		// From view.
		view.popUpWantsToCloseSignal.addOnce( onPopUpWantsToClose );
		view.popUpWantsToShareSignal.addOnce( onPopUpWantsToShare );
	}

	override public function destroy():void {
		super.destroy();
		if(view.bmd) view.bmd.dispose();
		//_sharer.completedSignal.remove(onUtilCompleted);
		//_sharer.dispose();
		
	}

	private function onPopUpWantsToShare():void {
		
		
		if(view.facebookChk.selected) _sharer.addSharer(new FacebookSharer(socialSharingManager));
		if(view.twitterChk.selected) _sharer.addSharer(new TwitterSharer(socialSharingManager));
		
		_sharer.completedSignal.add(onSharingCompleted);

		
		// Nothing to wait for, close.
		if(_sharer.numSharers == 0) exitPopUp();
		else _sharer.share([view.tf.text, view.bmd.clone()]);
		
		//WE ANIMATE THE BUTTONS OUT
		view.animateSideBtnsOut();
		
		//REMOVE THE SIGNAL TO LISTEN FOR THE CLOSING EVENT. WE WILL CLOSE WHEN FINISH SHARE 
		view.popUpWantsToCloseSignal.remove( onPopUpWantsToClose );
		view.popUpWantsToShareSignal.remove( onPopUpWantsToShare );
		
		if(_sharer.numSharers>0){
			requestShowPopUpSignal.dispatch(PopUpType.MESSAGE);
			requestUpdateMessagePopUpSignal.dispatch( "Sharing..." ,(view.facebookChk.selected)?"Throwing the painting on the Facebook Wall...":"Flying your painting to Twitter...");
		}
	}

	private function onSharingCompleted():void {
		//DISPOSE OF THE SHARER
		_sharer.completedSignal.remove(onSharingCompleted);
		_sharer.dispose();
		
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
		
		//REGULAR CLOSE THE POPUP POSITION, NOW WE CLOSE THE POPUP WHEN SHARING ON FACEBOOK
		//requestHidePopUpSignal.dispatch();
		
		requestShowPopUpSignal.dispatch(PopUpType.ERROR);
		requestUpdateMessagePopUpSignal.dispatch( "PUBLISHED" ,"The painting have been published already.");
	}

	private function onPopUpWantsToClose():void {
		//REMOVE THE SIGNAL AND SIMPLY CLOSE THE POPUP
		view.popUpWantsToCloseSignal.remove( onPopUpWantsToClose );
		view.popUpWantsToShareSignal.remove( onPopUpWantsToShare );
		
		requestHidePopUpSignal.dispatch();
		
	}
}
}
