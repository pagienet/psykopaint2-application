package net.psykosoft.psykopaint2.core.services
{
	public class AMFErrorCode
	{
		public static const NO_ERROR : int = 0x0000;

		public static const CALL_FAILED : int = 0x001;
		public static const CALL_STATUS_FAILED : int = 0x0002;
		public static const CALL_STATUS_ERROR : int = 0x0003;
		public static const CALL_STATUS_EXISTS : int = 0x0004;
		public static const CALL_STATUS_AUTH_ERROR : int = 0x0005;
		public static const CALL_STATUS_UNAUTHORIZED : int = 0x0010;

		public static const CONNECTION_REFUSED : int = 0x0100;
		public static const CONNECTION_IO_ERROR : int = 0x0101;
		public static const CONNECTION_SECURITY_ERROR : int = 0x0102;
		public static const UNKNOWN_RESPONSE : int = 0x103;
		public static const CONNECTION_ASYNC_ERROR : int = 0x104;
	}
}
