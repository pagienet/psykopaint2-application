package net.psykosoft.psykopaint2.core.views.popups.login
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.views.components.button.IconButtonAlt;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	import org.osflash.signals.Signal;

	public class LoginPopUpView extends PopUpViewBase
	{
		// Declared in Flash.
		public var bg:Sprite;
		public var selectLoginSubView:SelectLoginSubView;
		public var loginSubView:LoginSubView;
		public var signupSubView:SignupSubView;
		public var leftSide:Sprite;
		public var rightSide:Sprite;

		public var popUpWantsToCloseSignal:Signal;
		public var popUpWantsToLogInSignal:Signal;
		public var popUpRequestsForgottenPasswordSignal:Signal;
		public var popUpWantsToRegisterSignal:Signal;

		private var _leftButton:IconButtonAlt;
		private var _rightButton:IconButtonAlt;

		public function LoginPopUpView() {
			super();

			popUpWantsToCloseSignal = new Signal();
			popUpWantsToLogInSignal = new Signal();
			popUpRequestsForgottenPasswordSignal = new Signal();
			popUpWantsToRegisterSignal = new Signal();

			_leftButton = leftSide.getChildByName( "btn" ) as IconButtonAlt;
			_rightButton = rightSide.getChildByName( "btn" ) as IconButtonAlt;

			_leftButton.labelText = "BACK";
			_rightButton.labelText = "NEXT";

			_leftButton.label.visible = false;
			_rightButton.label.visible = false;

			_leftButton.iconType = "back";
			_rightButton.iconType = "continue";

			leftSide.visible = false;
			rightSide.visible = false;

			loginSubView.visible = false;
			signupSubView.visible = false;

			_leftButton.addEventListener( MouseEvent.CLICK, onLeftBtnClick );
			_rightButton.addEventListener( MouseEvent.CLICK, onRightBtnClick );
		}

		override public function onAnimatedIn():void {
			animateSideBtnsIn();
		}

		override public function onGoingToAnimateOut():void {
			animateSideBtnsOut();
		}

		override protected function onEnabled():void {

			super.onEnabled();

			_blocker.addEventListener( MouseEvent.CLICK, onBlockerClick );

			selectLoginSubView.loginClickedSignal.add( onSelectLoginSubViewLoginBtnClicked );
			selectLoginSubView.signupClickedSignal.add( onSelectLoginSubViewSignupBtnClicked );

			loginSubView.viewWantsToLogInSignal.add( onLoginViewWantsToLogIn );
			loginSubView.forgotBtnClickedSignal.add( onLoginViewForgotButtonClicked );

			signupSubView.viewWantsToRegisterSignal.add( onSignupViewWantsToRegister );

			layout();
		}

		override protected function onDisabled():void {

			_blocker.removeEventListener( MouseEvent.CLICK, onBlockerClick );

			_leftButton.removeEventListener( MouseEvent.CLICK, onLeftBtnClick );
			_rightButton.removeEventListener( MouseEvent.CLICK, onRightBtnClick );

			selectLoginSubView.loginClickedSignal.remove( onSelectLoginSubViewLoginBtnClicked );
			selectLoginSubView.signupClickedSignal.remove( onSelectLoginSubViewSignupBtnClicked );

			loginSubView.viewWantsToLogInSignal.remove( onLoginViewWantsToLogIn );
			loginSubView.forgotBtnClickedSignal.remove( onLoginViewForgotButtonClicked );

			signupSubView.viewWantsToRegisterSignal.remove( onSignupViewWantsToRegister );

			selectLoginSubView.dispose();
			loginSubView.dispose();
			signupSubView.dispose();
			_leftButton.dispose();
			_rightButton.dispose();

			super.onDisabled();
		}

		// -----------------------
		// Side btn animations.
		// -----------------------

		private function animateSideBtnsIn():void {

			leftSide.x = -leftSide.width;
			leftSide.y = 768 + leftSide.height;
			leftSide.visible = true;
			TweenLite.to( leftSide, 0.15, { x: 0, y: 790, ease: Strong.easeOut } );

			// Right side currently disabled.
//			rightSide.x = 1024 + rightSide.width;
//			rightSide.y = 768 + rightSide.height;
//			rightSide.visible = true;
//			TweenLite.to( rightSide, 0.15, { x: 1024, y: 790, ease: Strong.easeOut } );
		}

		private function animateSideBtnsOut():void {
			TweenLite.to( leftSide, 0.15, { x: -leftSide.width, y: 768 + leftSide.height, ease: Strong.easeIn, onComplete: onAnimateOutComplete, onCompleteParams: [ leftSide ] } );
//			TweenLite.to( rightSide, 0.15, { x: 1024 + rightSide.width, y: 768 + rightSide.height, ease: Strong.easeIn, onCompleteParams: [ rightSide ] } );
		}

		private function onAnimateOutComplete( target:MovieClip ):void {
			target.visible = false;
		}


		// -----------------------
		// Private.
		// -----------------------

		private function returnToSelectScreen():void {
			selectLoginSubView.visible = true;
			signupSubView.visible = loginSubView.visible = false;
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onRightBtnClick( event:MouseEvent ):void {
			// No functionality atm.
		}

		private function onLeftBtnClick( event:MouseEvent ):void {
			if( selectLoginSubView.visible ) popUpWantsToCloseSignal.dispatch();
			else returnToSelectScreen();
		}

		private function onSelectLoginBackBtnClicked():void {
			popUpWantsToCloseSignal.dispatch();
		}

		private function onRegisterWantsToGoBack():void {
			returnToSelectScreen();
		}

		private function onLoginWantsToGoBack():void {
			returnToSelectScreen();
		}

		private function onSignupViewWantsToRegister( email:String, password:String, firstName:String, lastName:String, photoLarge:BitmapData, photoSmall:BitmapData ):void {
			popUpWantsToRegisterSignal.dispatch( email, password, firstName, lastName, photoLarge, photoSmall );
		}

		private function onLoginViewForgotButtonClicked():void {
			popUpRequestsForgottenPasswordSignal.dispatch();
		}

		private function onLoginViewWantsToLogIn( email:String, password:String ):void {
			popUpWantsToLogInSignal.dispatch( email, password );
		}

		private function onSelectLoginSubViewSignupBtnClicked():void {
			selectLoginSubView.visible = false;
			signupSubView.visible = true;
		}

		private function onSelectLoginSubViewLoginBtnClicked():void {
			selectLoginSubView.visible = false;
			loginSubView.visible = true;
		}

		private function onBlockerClick( event:MouseEvent ):void {
			popUpWantsToCloseSignal.dispatch();
		}
	}
}
