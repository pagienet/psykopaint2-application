package net.psykosoft.psykopaint2.base.utils.misc
{

	import flash.display.DisplayObject;
	import flash.display.Stage;

	public class ClickUtil
	{
		public static function getObjectOfClassInHierarchy( target:DisplayObject, cl:Class ):DisplayObject {

			if( target is cl ) {
				return target;
			}
			else if( !( target is Stage ) ) {
				return getObjectOfClassInHierarchy( target.parent, cl );
			}

			return null;
		}
	}
}
