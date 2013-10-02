package net.psykosoft.psykopaint2.core.views.components.input
{

	public class PsykoInputValidationUtil
	{
		public static function validateEmailFormat( emailInput:PsykoInput ):int {
			if( emailInput.text.length == 0 || emailInput.text == emailInput.defaultText ) {
				emailInput.showRedHighlight();
				return 1;
			}
			var emailRegex:RegExp = /^[\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
			var isEmailValid:Boolean = emailRegex.test( emailInput.text );
			if( isEmailValid ) emailInput.showBlueHighlight();
			else {
				emailInput.showRedHighlight();
				return 2;
			}
			return 0;
		}

		public static function validatePasswordFormat( passwordInput:PsykoInput ):int {

			var enteredPassword:Boolean = passwordInput.text.length > 0 && passwordInput.text != passwordInput.defaultText;
			if( !enteredPassword ) {
				passwordInput.showRedHighlight();
				return 1;
			}

			var passwordIsLongEnough:Boolean = passwordInput.text.length < 6;
			if( !passwordIsLongEnough ) {
				passwordInput.showRedHighlight();
				return 2;
			}

			passwordInput.showBlueHighlight();

			return 0;
		}

		public static function validateNameFormat( nameInput:PsykoInput ):int {
			var isNameValid:Boolean = nameInput.text.length > 0 && nameInput.text != nameInput.defaultText;
			if( isNameValid ) nameInput.showBlueHighlight();
			else {
				nameInput.showRedHighlight();
				return 1;
			}
			return 0;
		}
	}
}
