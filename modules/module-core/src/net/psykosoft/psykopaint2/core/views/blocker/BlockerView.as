package net.psykosoft.psykopaint2.core.views.blocker
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class BlockerView extends Sprite
	{
		private var _blocker:Sprite;

		public function BlockerView() {
			super();

			_blocker = new Sprite();
			_blocker.graphics.beginFill( 0x000000, CoreSettings.SHOW_BLOCKER ? 0.75 : 0 );
			_blocker.graphics.drawRect( 0, 0, 1024 * CoreSettings.GLOBAL_SCALING, 768 * CoreSettings.GLOBAL_SCALING );
			_blocker.graphics.endFill();
			_blocker.visible = false;
			addChild( _blocker );
		}

		public function showBlocker( block:Boolean ):void {
			_blocker.visible = block;
		}
	}
}
