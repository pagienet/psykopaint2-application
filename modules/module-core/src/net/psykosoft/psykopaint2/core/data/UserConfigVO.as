package net.psykosoft.psykopaint2.core.data
{
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;

	public class UserConfigVO
	{
		public var userEmail:String;
		public var userPassword:String;
		public var trialMode:Boolean=false;
		private var _inventory:Object;
		//public var hasBrushKit1:Boolean;
		
		//public var hasFullVersion:Boolean;
		
		public function UserConfigVO() {
			super();
		}
		
		public function userOwns( containedInProducts:Vector.<String> ):Boolean
		{
			if ( containedInProducts.indexOf( InAppPurchaseManager.PRODUCT_ID_FREE ) > -1 ) return true;
			
			if ( _inventory == null ) {
				throw("Inventory not set yet? That should not happen - check initialization order");
				return false;
			}
			for ( var i:String in _inventory )
			{
				if ( containedInProducts.indexOf(i) > -1 ) return true;
			}
				
			return false;
		}
		
		public function setInventory(inventory:Object):void
		{
			_inventory = inventory;
		}
		
		public function markProductAsPurchased( productID:String ):void
		{
			_inventory[productID] = "purchased";
		}
				
	}
}
