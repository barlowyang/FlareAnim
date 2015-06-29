package
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class LitterByteArray extends ByteArray
	{
		public function LitterByteArray()
		{
			super();
			
			endian = Endian.LITTLE_ENDIAN;
		}
	}
}