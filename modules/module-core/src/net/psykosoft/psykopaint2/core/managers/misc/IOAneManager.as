package net.psykosoft.psykopaint2.core.managers.misc
{

	import net.psykosoft.io.IOExtension;

	public class IOAneManager
	{
		private var _extension:IOExtension;

		public function IOAneManager() {
			super();
		}

		public function initialize():void {
			_extension = new IOExtension();
		}

		public function get extension():IOExtension {
			return _extension;
		}
	}
}
