package net.psykosoft.psykopaint2.book.views.book
{

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	public class BookView extends ViewBase
	{
		public function BookView() {
			super();
		}

		override protected function onEnabled():void {
			this.graphics.beginFill( 0xFF0000, 1.0 );
			this.graphics.drawRect( 512, 512, 100, 100 );
			this.graphics.endFill();
		}

		override protected function onDisabled():void {
			graphics.clear();
		}
	}
}
