package net.psykosoft.psykopaint2.core.drawing.data
{

	public class ModuleActivationVO
	{
		public var activatedModuleType:String;
		public var deactivatedModuleType:String;
		public var concatenatingModuleType:String;

		public function ModuleActivationVO( activated:String, deactivated:String, concatenating:String ) {
			super();
			this.activatedModuleType = activated;
			this.deactivatedModuleType = deactivated;
			this.concatenatingModuleType = concatenating;
		}
	}
}
