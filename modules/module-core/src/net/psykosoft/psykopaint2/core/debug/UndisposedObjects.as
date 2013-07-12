package net.psykosoft.psykopaint2.core.debug
{
	public class UndisposedObjects
	{
		private static var _instance : UndisposedObjects;

		private var _collection : Vector.<UndisposedData>;

		public function UndisposedObjects()
		{
			if (_instance) throw "Cannot create more than one instance";

			_collection = new <UndisposedData>[];
		}

		// a singleton so we can keep an instance and inspect it in the debugger
		public static function getInstance() : UndisposedObjects
		{
			return _instance ||= new UndisposedObjects();
		}

		public function get numObjects() : uint
		{
			return _collection.length;
		}

		public function add(object : Object) : void
		{
			_collection.push(new UndisposedData(object));
		}

		public function remove(object : Object) : void
		{
			for (var i : int = 0; i < _collection.length; ++i) {
				var data : UndisposedData = _collection[i];
				if (data.object == object) {
					_collection.splice(i, 1);
					return;
				}
			}

			throw new Error("Object not found!");
		}
	}
}

class UndisposedData
{
	public function UndisposedData(object : Object)
	{
		this.object = object;
		allocationStackTrace = new Error("new()").getStackTrace();
	}

	public var object : Object;
	public var allocationStackTrace : String;
}