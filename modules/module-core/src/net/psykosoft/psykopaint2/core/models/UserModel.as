package net.psykosoft.psykopaint2.core.models
{

	public class UserModel
	{
		private var _uniqueUserId:String = "uniqueUserId"; // TODO...

		public function UserModel() {
			super();
		}

		public function get uniqueUserId():String {
			return _uniqueUserId;
		}
	}
}
