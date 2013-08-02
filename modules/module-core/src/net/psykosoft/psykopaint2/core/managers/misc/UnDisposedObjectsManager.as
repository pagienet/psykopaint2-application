package net.psykosoft.psykopaint2.core.managers.misc
{

	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	public class UnDisposedObjectsManager
	{
		private var _unDisposedObjects:UndisposedObjects;
		private var _oldNumUnDisposedObjects:uint;

		public function UnDisposedObjectsManager() {
			super();
			_unDisposedObjects = UndisposedObjects.getInstance();
		}

		public function update():void {
			if( _oldNumUnDisposedObjects != _unDisposedObjects.numObjects ) {
				trace( "Number of un-disposed objects changed to " + _unDisposedObjects.numObjects );
				_oldNumUnDisposedObjects = _unDisposedObjects.numObjects;
			}
		}
	}
}
