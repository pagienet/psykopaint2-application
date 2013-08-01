package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;

	public class TransitionCropToPaintState extends State
	{
		private var _croppedBitmapData : BitmapData;

		public function TransitionCropToPaintState()
		{
		}

		/**
		 *
		 * @param data A BitmapData containing the cropped bitmap
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			_croppedBitmapData = BitmapData(data);
		}

		override ns_state_machine function deactivate() : void
		{
		}
	}
}
