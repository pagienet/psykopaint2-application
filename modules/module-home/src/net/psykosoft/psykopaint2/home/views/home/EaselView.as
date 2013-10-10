package net.psykosoft.psykopaint2.home.views.home
{
	import away3d.entities.Mesh;

	import flash.display.Sprite;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;

	import org.osflash.signals.Signal;

	public class EaselView extends Sprite
	{
		public var easelRectChanged : Signal = new Signal();

		public function EaselView(easel : Mesh)
		{
		}

		public function get easelRect() : Rectangle
		{
			return new Rectangle();
		}

		// disposeWhenDone? what does this do?
		public function setContent(paintingVO : PaintingInfoVO, animateIn : Boolean = false, disposeWhenDone : Boolean = false) : void
		{

		}
	}
}
