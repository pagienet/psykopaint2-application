package net.psykosoft.psykopaint2.core.views.navigation
{
	import com.junkbyte.console.Cc;

	import flash.utils.Dictionary;

	public class CrStateToSubNavLinker
	{
		private static var _subNavDict:Dictionary;

		public static function getSubNavClassForState( state:String ):Class {
			if( !_subNavDict ) _subNavDict = new Dictionary();
			var cl:Class = _subNavDict[ state ];
			Cc.log( "CrStateToSubNavLinker - getSubNavClassForState() - state " + state + " corresponds to a sub-nav of type: " + cl );
			return cl;
		}

		public static function linkSubNavToState( state:String, subNav:Class ):void {
			if( !_subNavDict ) _subNavDict = new Dictionary();
			_subNavDict[ state ] = subNav;
		}
	}
}
