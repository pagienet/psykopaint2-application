package net.psykosoft.psykopaint2.home.views.newpainting
{

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import away3d.containers.View3D;

	import net.psykosoft.psykopaint2.base.ui.components.list.HSnapList;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.views.components.button.BitmapButton;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewDeleteModeChangedSignal;

	public class NewPaintingSubNavView extends SubNavigationViewBase
	{
		public static const ID_NEW:String = "New Painting";
		//public static const ID_NEW_PHOTO:String = "Photo Painting";

		private var _disabledId:String;
		private var paintingButtons:Vector.<BitmapButton>;
		public var deleteModeActive:Boolean;
		public var deleteModeSignal:NotifyHomeViewDeleteModeChangedSignal;
		
		public function NewPaintingSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
		}

		public function createNewPaintingButtons():void {
			createCenterButton( ID_NEW, "New Painting", ButtonIconType.NEW, IconButton );
			//createCenterButton( ID_NEW_PHOTO, ID_NEW_PHOTO, ButtonIconType.NEW_PAINTING_AUTO, IconButton );
		}

		public function createInProgressPaintings( data:Vector.<PaintingInfoVO>, unavailablePaintingId:String ):void {
			_disabledId = unavailablePaintingId;
			paintingButtons = new Vector.<BitmapButton>();
			deleteModeActive = false;
			
			var numPaintings:uint = data.length;
			for( var i:uint = 0; i < numPaintings; i++ ) {
				var vo:PaintingInfoVO = data[ i ];
				var dump:Array = vo.id.split( "-" );
				var str:String = dump[ dump.length - 1 ];
				var btnIsEnabled:Boolean = vo.id != unavailablePaintingId;
				var buttonData:ButtonData = createCenterButton( str, str, null, BitmapButton, new Bitmap( vo.thumbnail ), true, btnIsEnabled, false,"mouseUp",this,onButtonReady );
			}
		}

		public function enableDisabledButtons():void {
			enableButtonWithId( _disabledId, true );
		}
		
		private function onButtonReady( button:BitmapButton ):void
		{
			
			paintingButtons.push( button );
			button.addEventListener("VerticalSwipe", toggleDeleteMode );
			if ( deleteModeActive ) button.enterDeleteMode();
		}
		
		public function toggleDeleteMode(event:Event = null):void
		{
			trace("delete mode: ",deleteModeActive);
			for ( var i:int = 0; i < paintingButtons.length; i++ )
			{
				if ( !deleteModeActive ) paintingButtons[i].enterDeleteMode();
				else  paintingButtons[i].enterDefaultMode();
			}
			if ( !deleteModeActive ) {
				deleteModeActive = true;
				deleteModeSignal.dispatch(true);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageTapped );
			}
			else {
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageTapped );
				setTimeout( reenableDefaultMode,200 );
			}
		}
		
		protected function onStageTapped(event:MouseEvent):void
		{
			if ( event.target is Sprite && (event.target as Sprite).parent && (event.target as Sprite).parent is View3D )
			{
				toggleDeleteMode();
			}
			
		}
		
		private function reenableDefaultMode():void
		{
			deleteModeActive = false;
			deleteModeSignal.dispatch(false);
		}
		
		public function removePainting(id:String):void
		{
			trace("remove Painting "+id);
		//	removeButtonWithId(id);
			for ( var i:int = 0; i < paintingButtons.length; i++ )
			{
				if ( paintingButtons[i].id == id )
				{
					paintingButtons[i].deleted = !paintingButtons[i].deleted;
					_scroller.removeButtonWithId(id);
					return;
				}
				
			}
		}
	}
}
