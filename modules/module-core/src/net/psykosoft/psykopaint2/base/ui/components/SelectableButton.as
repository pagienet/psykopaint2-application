package net.psykosoft.psykopaint2.base.ui.components
{

	import flash.display.Sprite;

	public class SelectableButton extends PsykoButton
	{
		private var _pins:Sprite;

		public function SelectableButton() {
			super();
		}

		protected function setPins( pins:Sprite ):void {
			_pins = pins;
		}
	}
}
