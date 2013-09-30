package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.views.components.button.FoldButton;

	import net.psykosoft.psykopaint2.core.views.components.input.PsykoInput;

	public class SignupSubView extends Sprite
	{
		// Declared in Flash.
		public var emailTf:PsykoInput;
		public var passwordTf:PsykoInput;
		public var firstNameTf:PsykoInput;
		public var lastNameTf:PsykoInput;
		public var signupBtn:FoldButton;

		public function SignupSubView() {
			super();
		}

		public function dispose():void {

		}
	}
}
