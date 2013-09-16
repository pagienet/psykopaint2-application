package net.psykosoft.psykopaint2.core.signals
{

	import flash.geom.Matrix3D;

	import org.osflash.signals.Signal;

	public class NotifyGyroscopeUpdateSignal extends Signal
	{
		public function NotifyGyroscopeUpdateSignal() {
			super(Matrix3D);
		}
	}
}
